-- preassign ports necessary to bootstrap the docker image

insert into applications
(id, ports, dependencies, updated_by_user_id)
values
('registry-postgresql', '[{"service":{"id":"postgresql"},"internal":5432,"external":6019}]', '[]'::json, 'usr-20151006-1');

insert into applications
(id, ports, dependencies, updated_by_user_id)
values
('registry', '[{"service":{"id":"play"},"internal":9000,"external":6011}]'::json, '["registry-postgresql"]'::json, 'usr-20151006-1');

insert into ports
(id, application_id, service_id, external, internal, updated_by_user_id)
values
('prt-20160130-1', 'registry', 'play', 6011, 9000, 'usr-20151006-1');

insert into ports
(id, application_id, service_id, external, internal, updated_by_user_id)
values
('prt-20160130-2', 'registry-postgresql', 'play', 6019, 5432, 'usr-20151006-1');

insert into applications
(id, ports, dependencies, updated_by_user_id)
values
('user-postgresql', '[{"service":{"id":"postgresql"},"internal":5432,"external":6029}]', '[]'::json, 'usr-20151006-1');

insert into applications
(id, ports, dependencies, updated_by_user_id)
values
('user', '[{"service":{"id":"play"},"internal":9000,"external":6021}]'::json, '["user-postgresql", "registry"]'::json, 'usr-20151006-1');

insert into ports
(id, application_id, service_id, external, internal, updated_by_user_id)
values
('prt-20160130-3', 'user', 'play', 6021, 9000, 'usr-20151006-1');

insert into ports
(id, application_id, service_id, external, internal, updated_by_user_id)
values
('prt-20160130-4', 'user-postgresql', 'play', 6029, 5432, 'usr-20151006-1');

insert into dependencies
(id, application_id, dependency_id, updated_by_user_id)
values
('dep-20160130-1', 'registry', 'registry-postgresql', 'usr-20151006-1');

insert into dependencies
(id, application_id, dependency_id, updated_by_user_id)
values
('dep-20160130-2', 'user', 'user-postgresql', 'usr-20151006-1');

insert into dependencies
(id, application_id, dependency_id, updated_by_user_id)
values
('dep-20160130-3', 'user', 'registry', 'usr-20151006-1');
