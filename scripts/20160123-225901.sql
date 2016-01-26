drop table if exists ports;
drop table if exists applications;

create table applications (
  id                              text primary key check(util.lower_non_empty_trimmed_string(id))
);

comment on table applications is '
  A top level application. The id is the unique identifier of the app
  and likely maps to a git hub repo.
';

select audit.setup('public', 'applications');

create table ports (
  id                              text primary key,
  application_id                  text not null references applications,
  type                            text not null check(util.lower_non_empty_trimmed_string(type)),
  number                          bigint not null check(number > 0)
);

comment on table ports is '
  Keeps track of ports assigned to a given application,
  ensuring that no port is reused.
';

comment on column ports.type is '
  The application type running on this port.
';

select audit.setup('public', 'ports');
create index on ports(application_id);
create unique index on ports(number) where deleted_at is null;
