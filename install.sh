#!/bin/sh

psql -U postgres -c 'create database "registry"' postgres
psql -U postgres -c 'create role api login PASSWORD NULL' postgres
psql -U postgres -c 'GRANT ALL ON DATABASE "registry" TO api' postgres
sem-apply --user api --host localhost --name registry