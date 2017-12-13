#!/bin/sh

export logFile=logs/log_file.log

# Set these environmental variables
DATABASE=$(awk -F "=" '/database/ {print $2}' database.ini)
USERNAME=$(awk -F "=" '/user/ {print $2}' database.ini)
HOSTNAME=$(awk -F "=" '/host/ {print $2}' database.ini)
data1=$(awk -F "= " '/password/ {print $2}' database.ini)

# FILENAME=$1
file=$1

export PGPASSWORD=$data1

tmux new -s pcornet_etl

# for file in  $FILENAME; do
    echo $file
    psql -v ON_ERROR_STOP=1 -h $HOSTNAME -U $USERNAME $DATABASE -f $file
# done

tmux detach