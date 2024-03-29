CREATE OR REPLACE FUNCTION partman.create_partition_time(p_parent_table text, p_partition_times timestamp without time zone[], p_analyze boolean DEFAULT true)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE

ex_context                      text;
ex_detail                       text;
ex_hint                         text;
ex_message                      text;
v_all                           text[] := ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'];
v_analyze                       boolean := FALSE;
v_control                       text;
v_datetime_string               text;
v_exists                        text;
v_epoch                         boolean;
v_grantees                      text[];
v_hasoids                       boolean;
v_inherit_fk                    boolean;
v_job_id                        bigint;
v_jobmon                        boolean;
v_jobmon_schema                 text;
v_old_search_path               text;
v_parent_grant                  record;
v_parent_owner                  text;
v_parent_schema                 text;
v_parent_tablename              text;
v_partition_created             boolean := false;
v_partition_name                text;
v_partition_suffix              text;
v_parent_tablespace             text;
v_partition_interval            interval;
v_partition_timestamp_end       timestamp;
v_partition_timestamp_start     timestamp;
v_quarter                       text;
v_revoke                        text;
v_row                           record;
v_sql                           text;
v_step_id                       bigint;
v_step_overflow_id              bigint;
v_sub_timestamp_max             timestamp;
v_sub_timestamp_min             timestamp;
v_trunc_value                   text;
v_time                          timestamp;
v_type                          text;
v_unlogged                      char;
v_year                          text;

BEGIN

SELECT partition_type
    , control
    , partition_interval
    , epoch
    , inherit_fk
    , jobmon
    , datetime_string
INTO v_type
    , v_control
    , v_partition_interval
    , v_epoch
    , v_inherit_fk
    , v_jobmon
    , v_datetime_string
FROM partman.part_config
WHERE parent_table = p_parent_table
AND partition_type = 'time' OR partition_type = 'time-custom';

IF NOT FOUND THEN
    RAISE EXCEPTION 'ERROR: no config found for %', p_parent_table;
END IF;

IF v_jobmon THEN
    SELECT nspname INTO v_jobmon_schema FROM pg_catalog.pg_namespace n, pg_catalog.pg_extension e WHERE e.extname = 'pg_jobmon' AND e.extnamespace = n.oid;
    IF v_jobmon_schema IS NOT NULL THEN
        SELECT current_setting('search_path') INTO v_old_search_path;
        EXECUTE format('SELECT set_config(%L, %L, %L)', 'search_path', 'partman,'||v_jobmon_schema, 'false');
    END IF;
END IF;

-- Determine if this table is a child of a subpartition parent. If so, get limits of what child tables can be created based on parent suffix
SELECT sub_min::timestamp, sub_max::timestamp INTO v_sub_timestamp_min, v_sub_timestamp_max FROM partman.check_subpartition_limits(p_parent_table, 'time');

SELECT tableowner, schemaname, tablename, tablespace INTO v_parent_owner, v_parent_schema, v_parent_tablename, v_parent_tablespace FROM pg_catalog.pg_tables WHERE schemaname ||'.'|| tablename = p_parent_table;

IF v_jobmon_schema IS NOT NULL THEN
    v_job_id := add_job(format('PARTMAN CREATE TABLE: %s', p_parent_table));
END IF;

FOREACH v_time IN ARRAY p_partition_times LOOP
    v_partition_timestamp_start := v_time;
    BEGIN
        v_partition_timestamp_end := v_time + v_partition_interval;
    EXCEPTION WHEN datetime_field_overflow THEN
        RAISE WARNING 'Attempted partition time interval is outside PostgreSQL''s supported time range.
            Child partition creation after time % skipped', v_time;
        v_step_overflow_id := add_step(v_job_id, 'Attempted partition time interval is outside PostgreSQL''s supported time range.');
        PERFORM update_step(v_step_overflow_id, 'CRITICAL', 'Child partition creation after time '||v_time||' skipped');
        CONTINUE;
    END;

    -- Do not create the child table if it's outside the bounds of the top parent.
    IF v_sub_timestamp_min IS NOT NULL THEN
        IF v_time < v_sub_timestamp_min OR v_time > v_sub_timestamp_max THEN
            CONTINUE;
        END IF;
    END IF;

    -- This suffix generation code is in partition_data_time() as well
    v_partition_suffix := to_char(v_time, v_datetime_string);
    v_partition_name := partman.check_name_length(v_parent_tablename, v_partition_suffix, TRUE);
    SELECT tablename INTO v_exists FROM pg_catalog.pg_tables WHERE schemaname = v_parent_schema AND tablename = v_partition_name;
    IF v_exists IS NOT NULL THEN
        CONTINUE;
    END IF;

    -- Ensure analyze is run if a new partition is created. Otherwise if one isn't, will be false and analyze will be skipped
    v_analyze := TRUE;

    IF v_jobmon_schema IS NOT NULL THEN
        v_step_id := add_step(v_job_id, format('Creating new partition %s.%s with interval from %s to %s'
                                                , v_parent_schema
                                                , v_partition_name
                                                , v_partition_timestamp_start
                                                , v_partition_timestamp_end-'1sec'::interval));
    END IF;

    SELECT relpersistence INTO v_unlogged
    FROM pg_catalog.pg_class c
    JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
    WHERE c.relname = v_parent_tablename
    AND n.nspname = v_parent_schema;
    v_sql := 'CREATE';
    IF v_unlogged = 'u' THEN
        v_sql := v_sql || ' UNLOGGED';
    END IF;
    v_sql := v_sql || format(' TABLE %I.%I (LIKE %I.%I INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING INDEXES INCLUDING STORAGE INCLUDING COMMENTS)'
                                , v_parent_schema
                                , v_partition_name
                                , v_parent_schema
                                , v_parent_tablename);
    EXECUTE v_sql;
    IF v_parent_tablespace IS NOT NULL THEN
        EXECUTE format('ALTER TABLE %I.%I SET TABLESPACE %I', v_parent_schema, v_partition_name, v_parent_tablespace);
    END IF;
    IF v_epoch = false THEN
        EXECUTE format('ALTER TABLE %I.%I ADD CONSTRAINT %I CHECK (%I >= %L AND %I < %L)'
                        , v_parent_schema
                        , v_partition_name
                        , v_partition_name||'_partition_check'
                        , v_control
                        , v_partition_timestamp_start
                        , v_control
                        , v_partition_timestamp_end);
    ELSE
        EXECUTE format('ALTER TABLE %I.%I ADD CONSTRAINT %I CHECK (to_timestamp(%I) >= %L AND to_timestamp(%I) < %L)'
                        , v_parent_schema
                        , v_partition_name
                        , v_partition_name||'_partition_check'
                        , v_control
                        , v_partition_timestamp_start
                        , v_control
                        , v_partition_timestamp_end);
    END IF;

    EXECUTE format('ALTER TABLE %I.%I INHERIT %I.%I'
                    , v_parent_schema
                    , v_partition_name
                    , v_parent_schema
                    , v_parent_tablename);

    -- If custom time, set extra config options.
    IF v_type = 'time-custom' THEN
        INSERT INTO partman.custom_time_partitions (parent_table, child_table, partition_range)
        VALUES ( p_parent_table, v_parent_schema||'.'||v_partition_name, tstzrange(v_partition_timestamp_start, v_partition_timestamp_end, '[)') );
    END IF;

    FOR v_parent_grant IN
        SELECT array_agg(DISTINCT privilege_type::text ORDER BY privilege_type::text) AS types, grantee
        FROM information_schema.table_privileges
        WHERE table_schema ||'.'|| table_name = p_parent_table
        GROUP BY grantee
    LOOP
        EXECUTE format('GRANT %s ON %I.%I TO %I'
                        , array_to_string(v_parent_grant.types, ',')
                        , v_parent_schema
                        , v_partition_name
                        , v_parent_grant.grantee);
        SELECT string_agg(r, ',') INTO v_revoke FROM (SELECT unnest(v_all) AS r EXCEPT SELECT unnest(v_parent_grant.types)) x;
        IF v_revoke IS NOT NULL THEN
            EXECUTE format('REVOKE %s ON %I.%I FROM %I CASCADE'
                            , v_revoke
                            , v_parent_schema
                            , v_partition_name
                            , v_parent_grant.grantee);
        END IF;
        v_grantees := array_append(v_grantees, v_parent_grant.grantee::text);
    END LOOP;
    -- Revoke all privileges from roles that have none on the parent
    IF v_grantees IS NOT NULL THEN
        FOR v_row IN
            SELECT role FROM (
                SELECT DISTINCT grantee::text AS role FROM information_schema.table_privileges WHERE table_schema = v_parent_schema AND table_name = v_partition_name
                EXCEPT
                SELECT unnest(v_grantees)) x
        LOOP
            IF v_row.role IS NOT NULL THEN
                EXECUTE format('REVOKE ALL ON %I.%I FROM %I'
                            , v_parent_schema
                            , v_partition_name
                            , v_row.role);
            END IF;
        END LOOP;

    END IF;

    EXECUTE format('ALTER TABLE %I.%I OWNER TO %I', v_parent_schema, v_partition_name, v_parent_owner);

    IF v_inherit_fk THEN
        PERFORM partman.apply_foreign_keys(p_parent_table, v_parent_schema||'.'||v_partition_name, v_job_id);
    END IF;

    IF v_jobmon_schema IS NOT NULL THEN
        PERFORM update_step(v_step_id, 'OK', 'Done');
    END IF;

    -- Will only loop once and only if sub_partitioning is actually configured
    -- This seemed easier than assigning a bunch of variables then doing an IF condition
    FOR v_row IN
        SELECT sub_parent
            , sub_control
            , sub_partition_type
            , sub_partition_interval
            , sub_constraint_cols
            , sub_premake
            , sub_inherit_fk
            , sub_retention
            , sub_retention_schema
            , sub_retention_keep_table
            , sub_retention_keep_index
            , sub_use_run_maintenance
            , sub_epoch
            , sub_optimize_trigger
            , sub_optimize_constraint
            , sub_jobmon
        FROM partman.part_config_sub
        WHERE sub_parent = p_parent_table
    LOOP
        IF v_jobmon_schema IS NOT NULL THEN
            v_step_id := add_step(v_job_id, format('Subpartitioning %s.%s', v_parent_schema, v_partition_name));
        END IF;
        v_sql := format('SELECT partman.create_parent(
                 p_parent_table := %L
                , p_control := %L
                , p_type := %L
                , p_interval := %L
                , p_constraint_cols := %L
                , p_premake := %L
                , p_use_run_maintenance := %L
                , p_inherit_fk := %L
                , p_epoch := %L
                , p_jobmon := %L )'
            , v_parent_schema||'.'||v_partition_name
            , v_row.sub_control
            , v_row.sub_partition_type
            , v_row.sub_partition_interval
            , v_row.sub_constraint_cols
            , v_row.sub_premake
            , v_row.sub_use_run_maintenance
            , v_row.sub_inherit_fk
            , v_row.sub_epoch
            , v_row.sub_jobmon);
        EXECUTE v_sql;

        UPDATE partman.part_config SET
            retention_schema = v_row.sub_retention_schema
            , retention_keep_table = v_row.sub_retention_keep_table
            , retention_keep_index = v_row.sub_retention_keep_index
            , optimize_trigger = v_row.sub_optimize_trigger
            , optimize_constraint = v_row.sub_optimize_constraint
        WHERE parent_table = v_parent_schema||'.'||v_partition_name;

    END LOOP; -- end sub partitioning LOOP

    v_partition_created := true;

END LOOP;

-- v_analyze is a local check if a new table is made.
-- p_analyze is a parameter to say whether to run the analyze at all. Used by create_parent() to avoid long exclusive lock or run_maintenence() to avoid long creation runs.
IF v_analyze AND p_analyze THEN
    IF v_jobmon_schema IS NOT NULL THEN
        v_step_id := add_step(v_job_id, format('Analyzing partition set: %s', p_parent_table));
    END IF;

    EXECUTE format('ANALYZE %I.%I', v_parent_schema, v_parent_tablename);

    IF v_jobmon_schema IS NOT NULL THEN
        PERFORM update_step(v_step_id, 'OK', 'Done');
    END IF;
END IF;

IF v_jobmon_schema IS NOT NULL THEN
    IF v_partition_created = false THEN
        v_step_id := add_step(v_job_id, format('No partitions created for partition set: %s. Attempted intervals: %s', p_parent_table, p_partition_times));
        PERFORM update_step(v_step_id, 'OK', 'Done');
    END IF;

    IF v_step_overflow_id IS NOT NULL THEN
        PERFORM fail_job(v_job_id);
    ELSE
        PERFORM close_job(v_job_id);
    END IF;
END IF;

IF v_jobmon_schema IS NOT NULL THEN
    EXECUTE format('SELECT set_config(%L, %L, %L)', 'search_path', v_old_search_path, 'false');
END IF;

RETURN v_partition_created;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS ex_message = MESSAGE_TEXT,
                                ex_context = PG_EXCEPTION_CONTEXT,
                                ex_detail = PG_EXCEPTION_DETAIL,
                                ex_hint = PG_EXCEPTION_HINT;
        IF v_jobmon_schema IS NOT NULL THEN
            IF v_job_id IS NULL THEN
                EXECUTE format('SELECT %I.add_job(''PARTMAN CREATE TABLE: %s'')', v_jobmon_schema, p_parent_table) INTO v_job_id;
                EXECUTE format('SELECT %I.add_step(%s, ''EXCEPTION before job logging started'')', v_jobmon_schema, v_job_id, p_parent_table) INTO v_step_id;
            ELSIF v_step_id IS NULL THEN
                EXECUTE format('SELECT %I.add_step(%s, ''EXCEPTION before first step logged'')', v_jobmon_schema, v_job_id) INTO v_step_id;
            END IF;
            EXECUTE format('SELECT %I.update_step(%s, ''CRITICAL'', %L)', v_jobmon_schema, v_step_id, 'ERROR: '||coalesce(SQLERRM,'unknown'));
            EXECUTE format('SELECT %I.fail_job(%s)', v_jobmon_schema, v_job_id);
        END IF;
        RAISE EXCEPTION '%
CONTEXT: %
DETAIL: %
HINT: %', ex_message, ex_context, ex_detail, ex_hint;
END
$function$
