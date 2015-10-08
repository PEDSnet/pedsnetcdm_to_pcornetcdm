#!/bin/bash

export DUMPFILENAME="pcornetcdm_colorado_test.dump.psql"      && echo "Beginning Dump of Datbase $DATABASE" > log/"$DATABASE"_dump.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   pg_dump
 --host="$DBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE"  --no-privileges --no-owner --schema="pcornet_cdm"  --schema="pedsnet_cdm" --schema="public" --file="pedsne
t_chop_test.dump.psql"
