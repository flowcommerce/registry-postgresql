insert into applications
(id, ports, updated_by_user_id)
values
('registry', '[{"service":{"id":"play"},"internal":9000,"external":6011}]'::json, 'usr-20151006-1');

insert into applications
(id, ports, updated_by_user_id)
values
('registry-postgresql', '[{"service":{"id":"postgresql"},"internal":5432,"external":6019}]', 'usr-20151006-1');

insert into ports
(id, application_id, service_id, external, internal, updated_by_user_id)
values
('prt-20160130-1', 'registry', 'play', 6011, 9000, 'usr-20151006-1');

insert into ports
(id, application_id, service_id, external, internal, updated_by_user_id)
values
('prt-20160130-2', 'registry-postgresql', 'play', 6019, 5432, 'usr-20151006-1');

