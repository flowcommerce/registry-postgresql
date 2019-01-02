create or replace function recreate_journal(p_table_name text, p_timeframe text, p_retention text)  RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  execute 'drop table if exists journal.' || p_table_name || ' cascade;';
  delete from partman.part_config where parent_table = 'journal.' || p_table_name;

  perform journal.refresh_journaling('public', p_table_name, 'journal', p_table_name);
  perform partman.create_parent('journal.' || p_table_name, 'journal_timestamp', 'time', p_timeframe);

  update partman.part_config
     set retention = p_retention,
         retention_keep_table = false,
         retention_keep_index = false
   where parent_table = 'journal.' || p_table_name;
end;
$$;

select recreate_journal('services', 'monthly', '6 months');

drop function recreate_journal(text, text, text);
