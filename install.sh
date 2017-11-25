#!/bin/sh

psql -U postgres -c 'create database registrydb' postgres
psql -U postgres -c 'create role api login PASSWORD NULL' postgres > /dev/null
psql -U postgres -c 'GRANT ALL ON DATABASE registrydb TO api' postgres
sem-apply --url postgresql://api@localhost/registrydb
