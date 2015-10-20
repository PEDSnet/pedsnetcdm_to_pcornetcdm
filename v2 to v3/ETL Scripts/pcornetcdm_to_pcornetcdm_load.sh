#!/bin/bash

echo "Beginning Load of Datbase ${DATABASE}" > log/"$LOGFILENAME".log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE"   < dumps/"${DUMPFILENAME}"


echo "Beginning Load of Datbase ${DATABASE}" > log/$LOGFILENAME && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE"   < dumps/${DUMPFILENAME}
