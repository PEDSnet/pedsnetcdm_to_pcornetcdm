#!/usr/bin/env bash
set -e
set -u

# Set these environmental variables
DATABASE=$(awk -F "=" '/database/ {print $2}' database.ini)
USERNAME=$(awk -F "=" '/user/ {print $2}' database.ini)
HOSTNAME=$(awk -F "=" '/host/ {print $2}' database.ini)
data1=$(awk -F "= " '/password/ {print $2}' database.ini)

file=$1
export PGPASSWORD=$data1

psql_exit_status=$?

if [ $psql_exit_status != 0 ]; then
     echo "psql failed while trying to run this sql script" 1>&2
     exit $psql_exit_status
   fi

var=$(psql -X -U $USERNAME -h $HOSTNAME \
  -f $file \
  --echo-all \
  --set AUTOCOMMIT=off \
  --set ON_ERROR_STOP=on \
  $DATABASE)

echo $var