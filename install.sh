#!/bin/sh

psql -U postgres -c 'create database registrydb' postgres
psql -U postgres -c 'create role api login PASSWORD NULL' postgres > /dev/null
psql -U postgres -c 'GRANT ALL ON DATABASE registrydb TO api' postgres
psql -U postgres -c 'grant all on schema public to api' registrydb
sem-apply --url postgresql://api@localhost/registrydb
