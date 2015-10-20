#!/bin/bash

SCHEMAOWNER=dcc_owner

HOSTNAME=$LOADDBHOSTNAME

HOSTNAME=localhost

PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$HOSTNAME" --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" -c "alter database pedsnet_nationwide owner to $SCHEMAOWNER;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$HOSTNAME" --user="$ETL_DATABASE_USER"  --dbname="{$DATABASE}" -c "alter schema pedsnet_nationwide owner to $SCHEMAOWNER;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$HOSTNAME" --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" -c "alter schema pcornet_cdm owner to $SCHEMAOWNER;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$HOSTNAME" --user="$ETL_DATABASE_USER"  --dbname="{$DATABASE}" -c "alter schema public owner to $SCHEMAOWNER;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$HOSTNAME" --user="$ETL_DATABASE_USER"  --dbname="{$DATABASE}" -c "alter table public.measurement owner to $SCHEMAOWNER;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$HOSTNAME" --user="$ETL_DATABASE_USER"  --dbname="{$DATABASE}" -c "set role $SCHEMAOWNER;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$HOSTNAME" --user="$ETL_DATABASE_USER"  --dbname="{$DATABASE}" -c "select * from public.measurement;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$HOSTNAME" --user="$ETL_DATABASE_USER"  --dbname="{$DATABASE}" -c "select * from public.measurement limit 1;"

for tbl in `PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$HOSTNAME" --user="davidsonl2" --dbname="${DATABASE}" -qAt -c "select tablename from pg_tables where schemaname = 'public';"` ; do  PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$LOADDBHOSTNAME" --user="davidsonl2" --dbname="${DATABASE}" -c "alter table public.\"$tbl\" owner to $SCHEMAOWNER" ; done

for tbl in `PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$HOSTNAME" --user="davidsonl2" --dbname="${DATABASE}" -qAt -c "select tablename from pg_tables where schemaname = 'pcornet_cdm';"` ; do  PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$LOADDBHOSTNAME" --user="davidsonl2" --dbname="${DATABASE}" -c "alter table pcornet_cdm.\"$tbl\" owner to $SCHEMAOWNER" ; done

for tbl in `PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$HOSTNAME" --user="davidsonl2" --dbname="${DATABASE}" -qAt -c "select tablename from pg_tables where schemaname = 'pedsnet_cdm';"` ; do  PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="$LOADDBHOSTNAME" --user="davidsonl2" --dbname="${DATABASE}" -c "alter table pedsnet_cdm.\"$tbl\" owner to $SCHEMAOWNER" ; done


Load (Production)

psql  --dbname="$DATABASE" -c "alter schema pcornet_cdm owner to $SCHEMAOWNER;"
