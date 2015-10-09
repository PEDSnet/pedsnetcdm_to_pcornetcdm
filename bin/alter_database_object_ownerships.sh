#!/bin/bash

PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2"  --dbname="{$DATABASE}" -c "alter database pedsnet_nationwide owner to pcor_et_user;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2"  --dbname="{$DATABASE}" -c "alter schema pedsnet_nationwide owner to pcor_et_user;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2"  --dbname="{$DATABASE}" -c "alter schema pcornet_cdm owner to pcor_et_user;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2"  --dbname="{$DATABASE}" -c "alter schema public owner to pcor_et_user;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2"  --dbname="{$DATABASE}" -c "alter table public.measurement owner to pcor_et_user;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2"  --dbname="{$DATABASE}" -c "set role pcor_et_user;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2"  --dbname="{$DATABASE}" -c "select * from public.measurement;"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2"  --dbname="{$DATABASE}" -c "select * from public.measurement limit 1;"

for tbl in `PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2" --dbname="${DATABASE}" -qAt -c "select tablename from pg_tables where schemaname = 'public';"` ; do  PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2" --dbname="${DATABASE}" -c "alter table public.\"$tbl\" owner to pcor_et_user" ; done

for tbl in `PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2" --dbname="${DATABASE}" -qAt -c "select tablename from pg_tables where schemaname = 'pcornet_cdm';"` ; do  PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2" --dbname="${DATABASE}" -c "alter table pcornet_cdm.\"$tbl\" owner to pcor_et_user" ; done

for tbl in `PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2" --dbname="${DATABASE}" -qAt -c "select tablename from pg_tables where schemaname = 'pedsnet_cdm';"` ; do  PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" psql --host="reslnpedsndb02.research.chop.edu" --user="davidsonl2" --dbname="${DATABASE}" -c "alter table pedsnet_cdm.\"$tbl\" owner to pcor_et_user" ; done
