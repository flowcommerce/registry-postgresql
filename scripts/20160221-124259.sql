-- keep splashpage at 6040-6049, since these are the ports in production already
insert into applications (id, ports, dependencies, updated_by_user_id) values
('splashpage',               '[{"service":{"id":"play"},"internal":9000,"external":6041}]'::json, '["user", "splashpage-postgresql"]'::json, 'usr-20151006-1'),
('splashpage-postgresql',    '[{"service":{"id":"postgresql"},"internal":5432,"external":6049}]'::json, '[]'::json, 'usr-20151006-1'),
('www',                      '[{"service":{"id":"play"},"internal":9000,"external":6050}]'::json, '["splashpage"]'::json, 'usr-20151006-1'),
('fulfillment',              '[{"service":{"id":"play"},"internal":9000,"external":6061}]'::json, '["user", "fulfillment-postgresql"]'::json, 'usr-20151006-1'),
('fulfillment-postgresql',   '[{"service":{"id":"postgresql"},"internal":5432,"external":6059}]'::json, '[]'::json, 'usr-20151006-1'),
('catalog',                  '[{"service":{"id":"play"},"internal":9000,"external":6071}]'::json, '["user", "catalog-postgresql"]'::json, 'usr-20151006-1'),
('catalog-postgresql',       '[{"service":{"id":"postgresql"},"internal":5432,"external":6069}]'::json, '[]'::json, 'usr-20151006-1'),
('organization',             '[{"service":{"id":"play"},"internal":9000,"external":6081}]'::json, '["user", "organization-postgresql"]'::json, 'usr-20151006-1'),
('organization-postgresql',  '[{"service":{"id":"postgresql"},"internal":5432,"external":6079}]'::json, '[]'::json, 'usr-20151006-1'),
('delta-api',                '[{"service":{"id":"play"},"internal":9000,"external":6091}]'::json, '["delta-postgresql"]'::json, 'usr-20151006-1'),
('delta-www',                '[{"service":{"id":"play"},"internal":9000,"external":6090}]'::json, '["delta"]'::json, 'usr-20151006-1'),
('delta-postgresql',         '[{"service":{"id":"postgresql"},"internal":5432,"external":6099}]'::json, '[]'::json, 'usr-20151006-1');

-- keep splashpage at 6040-6049, since these are the ports in production already
insert into ports (id, application_id, service_id, external, internal, updated_by_user_id) values
('prt-20160221-103', 'splashpage',               'play',       6041, 9000, 'usr-20151006-1'),
('prt-20160221-104', 'splashpage-postgresql',    'postgresql', 6049, 5432, 'usr-20151006-1'),
('prt-20160221-105', 'www',                      'nodejs',     6050, 7050, 'usr-20151006-1'),
('prt-20160221-106', 'fulfillment',              'play',       6061, 9000, 'usr-20151006-1'),
('prt-20160221-107', 'fulfillment-postgresql',   'postgresql', 6069, 5432, 'usr-20151006-1'),
('prt-20160221-108', 'catalog',                  'play',       6071, 9000, 'usr-20151006-1'),
('prt-20160221-109', 'catalog-postgresql',       'postgresql', 6079, 5432, 'usr-20151006-1'),
('prt-20160221-110', 'organization',             'play',       6081, 9000, 'usr-20151006-1'),
('prt-20160221-111', 'organization-postgresql',  'postgresql', 6089, 5432, 'usr-20151006-1'),
('prt-20160221-112', 'delta-www',                'play',       6090, 9000, 'usr-20151006-1'),
('prt-20160221-113', 'delta-api',                'play',       6091, 9000, 'usr-20151006-1'),
('prt-20160221-114', 'delta-postgresql',         'postgresql', 6099, 5432, 'usr-20151006-1');

insert into dependencies (id, application_id, dependency_id, updated_by_user_id) values
('dep-20160221-103', 'splashpage',    'splashpage-postgresql', 'usr-20151006-1'),
('dep-20160221-104', 'splashpage',    'user', 'usr-20151006-1'),
('dep-20160221-105', 'www',           'splashpage', 'usr-20151006-1'),
('dep-20160221-106', 'fulfillment',   'fulfillment-postgresql', 'usr-20151006-1'),
('dep-20160221-107', 'fulfillment',   'user', 'usr-20151006-1'),
('dep-20160221-108', 'catalog',       'catalog-postgresql', 'usr-20151006-1'),
('dep-20160221-109', 'catalog',       'user', 'usr-20151006-1'),
('dep-20160221-110', 'organization',  'organization-postgresql', 'usr-20151006-1'),
('dep-20160221-111', 'organization',  'user', 'usr-20151006-1'),
('dep-20160221-112', 'delta-api',     'delta-postgresql', 'usr-20151006-1'),
('dep-20160221-113', 'delta-api',     'registry', 'usr-20151006-1'),
('dep-20160221-114', 'delta-api',     'user', 'usr-20151006-1'),
('dep-20160221-115', 'delta-www',     'delta-api', 'usr-20151006-1');
