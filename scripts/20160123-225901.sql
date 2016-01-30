drop table if exists ports;
drop table if exists applications;
drop table if exists services;

create table services (
  id                              text primary key check(util.lower_non_empty_trimmed_string(id)),
  default_port                    bigint not null check(default_port > 0)
);

select audit.setup('public', 'services');

comment on table services is '
  Defines services that listen on ports - e.g. postgresql, nodejs, play, etc.
  See https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.txt
';

create table applications (
  id                              text primary key check(util.lower_non_empty_trimmed_string(id)),
  ports                           json not null
);

comment on table applications is '
  A top level application. The id is the unique identifier of the app
  and likely maps to a git hub repo.
';

comment on column applications.ports is '
  The ports for this application. Stores as a list of json objects
  corresponding to the port model defined at
  http://apidoc.me/flow/registry/latest#model-port
';

select audit.setup('public', 'applications');

create table ports (
  id                              text primary key,
  application_id                  text not null references applications deferrable initially deferred,
  service_id                      text not null references services,
  external                        bigint not null unique check(external > 0),
  internal                        bigint not null check(internal > 0)
);

select audit.setup('public', 'ports');

comment on table ports is '
  A denormalization of the port numbers to serve as an index to enable
  faster allocation of unused ports, and also enforce that all of our
  external port allocations are unique.
';

create index on ports(application_id);
create index on ports(service_id);
