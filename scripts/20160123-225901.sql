drop table if exists ports;
drop table if exists applications;

create table applications (
  id                              text primary key check(util.lower_non_empty_trimmed_string(id)),
  ports                           json not null
);

comment on table applications is '
  A top level application. The id is the unique identifier of the app
  and likely maps to a git hub repo.
';

comment on column applications.ports is '
  A denormalization of the ports table for this
  application. Introduced to enable versioning of ports for the
  journal.
';

select audit.setup('public', 'applications');

create table ports (
  id                              text primary key,
  application_id                  text not null references applications deferrable initially deferred,
  type                            text not null check(util.lower_non_empty_trimmed_string(type)),
  num                             bigint not null unique check(num > 0)
);

comment on table ports is '
  Keeps track of ports assigned to a given application, ensuring that
  no port is reused. This table is essentially an index to enable
  faster allocation of unused ports, and also enforces that all of our
  port allocations are unique.
';

comment on column ports.type is '
  The application type running on this port.
';

select audit.setup('public', 'ports');
create index on ports(application_id);

