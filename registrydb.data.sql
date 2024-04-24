--
-- PostgreSQL database dump
--

-- Dumped from database version 15.5
-- Dumped by pg_dump version 15.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: part_config; Type: TABLE DATA; Schema: partman5; Owner: api
--

COPY partman5.part_config (parent_table, control, partition_interval, partition_type, premake, automatic_maintenance, template_table, retention, retention_schema, retention_keep_index, retention_keep_table, epoch, constraint_cols, optimize_constraint, infinite_time_partitions, datetime_string, jobmon, sub_partition_set_full, undo_in_progress, inherit_privileges, constraint_valid, ignore_default_data, default_table, date_trunc_interval, maintenance_order, retention_keep_publication, maintenance_last_run) FROM stdin;
journal.applications	journal_timestamp	1 mon	range	4	on	partman5.template_journal_applications	3 months	\N	f	f	none	\N	30	t	YYYYMMDD	t	f	f	f	t	t	f	\N	\N	f	2024-04-24 12:51:42.817008+00
journal.dependencies	journal_timestamp	1 mon	range	4	on	partman5.template_journal_dependencies	3 months	\N	f	f	none	\N	30	t	YYYYMMDD	t	f	f	f	t	t	f	\N	\N	f	2024-04-24 12:51:43.135498+00
journal.ports	journal_timestamp	1 mon	range	4	on	partman5.template_journal_ports	3 months	\N	f	f	none	\N	30	t	YYYYMMDD	t	f	f	f	t	t	f	\N	\N	f	2024-04-24 12:51:43.428059+00
journal.services	journal_timestamp	1 mon	range	4	on	partman5.template_journal_services	3 months	\N	f	f	none	\N	30	t	YYYYMMDD	t	f	f	f	t	t	f	\N	\N	f	2024-04-24 12:51:43.733088+00
\.


--
-- Data for Name: part_config_sub; Type: TABLE DATA; Schema: partman5; Owner: api
--

COPY partman5.part_config_sub (sub_parent, sub_control, sub_partition_interval, sub_partition_type, sub_premake, sub_automatic_maintenance, sub_template_table, sub_retention, sub_retention_schema, sub_retention_keep_index, sub_retention_keep_table, sub_epoch, sub_constraint_cols, sub_optimize_constraint, sub_infinite_time_partitions, sub_jobmon, sub_inherit_privileges, sub_constraint_valid, sub_ignore_default_data, sub_default_table, sub_date_trunc_interval, sub_maintenance_order, sub_retention_keep_publication) FROM stdin;
\.


--
-- Data for Name: template_journal_applications; Type: TABLE DATA; Schema: partman5; Owner: api
--

COPY partman5.template_journal_applications (id, ports, dependencies, created_at, updated_by_user_id, journal_timestamp, journal_operation, journal_id) FROM stdin;
\.


--
-- Data for Name: template_journal_dependencies; Type: TABLE DATA; Schema: partman5; Owner: api
--

COPY partman5.template_journal_dependencies (id, application_id, dependency_id, created_at, updated_by_user_id, journal_timestamp, journal_operation, journal_id) FROM stdin;
\.


--
-- Data for Name: template_journal_ports; Type: TABLE DATA; Schema: partman5; Owner: api
--

COPY partman5.template_journal_ports (id, application_id, service_id, external, internal, created_at, updated_by_user_id, journal_timestamp, journal_operation, journal_id) FROM stdin;
\.


--
-- Data for Name: template_journal_services; Type: TABLE DATA; Schema: partman5; Owner: api
--

COPY partman5.template_journal_services (id, default_port, created_at, updated_by_user_id, journal_timestamp, journal_operation, journal_id) FROM stdin;
\.


--
-- Data for Name: bootstrap_scripts; Type: TABLE DATA; Schema: schema_evolution_manager; Owner: api
--

COPY schema_evolution_manager.bootstrap_scripts (id, filename, created_at) FROM stdin;
1	20130318-105434.sql	2016-02-17 22:31:58.339293+00
2	20130318-105456.sql	2016-02-17 22:31:58.492568+00
\.


--
-- Data for Name: scripts; Type: TABLE DATA; Schema: schema_evolution_manager; Owner: api
--

COPY schema_evolution_manager.scripts (id, filename, created_at) FROM stdin;
1	20160123-225558.sql	2016-02-17 22:31:59.093017+00
2	20160123-225901.sql	2016-02-17 22:32:03.130456+00
3	20160127-213631.sql	2016-02-17 22:32:03.263116+00
4	20160130-125408.sql	2016-02-17 22:32:03.415866+00
5	20160221-124259.sql	2016-02-21 19:00:52.882064+00
6	20160823-144517.sql	2017-11-19 16:39:49.858763+00
7	20160909-093108.sql	2017-11-19 16:39:49.952388+00
8	20190102-095118.sql	2019-01-02 14:52:05.241624+00
9	20240201-174511.sql	2024-02-02 19:29:24.633597+00
10	20240201-174512.sql	2024-02-02 19:29:24.7343+00
11	20240201-174513.sql	2024-02-02 19:29:24.821396+00
12	20231129-221255.sql	2024-03-04 20:00:22.058439+00
13	20240423-122413.sql	2024-04-23 13:17:25.161731+00
14	20240423-122414.sql	2024-04-23 13:17:29.500062+00
\.


--
-- Name: bootstrap_scripts_id_seq; Type: SEQUENCE SET; Schema: schema_evolution_manager; Owner: api
--

SELECT pg_catalog.setval('schema_evolution_manager.bootstrap_scripts_id_seq', 2, true);


--
-- Name: scripts_id_seq; Type: SEQUENCE SET; Schema: schema_evolution_manager; Owner: api
--

SELECT pg_catalog.setval('schema_evolution_manager.scripts_id_seq', 14, true);


--
-- PostgreSQL database dump complete
--

