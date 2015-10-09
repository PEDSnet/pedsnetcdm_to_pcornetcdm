#!/bin/bash

echo "Beginning Dump of Datbase ${DATABASE}" > log/"$DUMPFILENAME".log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  pg_dump --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" --clean --create  --no-privileges --no-owner --schema="pcornet_cdm"  --schema="pedsnet_cdm" --schema="public" --file=dumps/"${DUMPFILENAME}"
