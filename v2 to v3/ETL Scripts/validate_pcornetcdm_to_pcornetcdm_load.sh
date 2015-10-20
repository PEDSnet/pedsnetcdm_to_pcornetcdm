#!/bin/bash

export SCRIPTNAME="validate_pcornetcdm_to_pcornetcdm_load"

NOW=`date +%Y%m%d%H%M%S`

VALIDATEDATABASE=$DATABASE

LOGFILENAME="$SCRIPTNAME.$VALIDATEDATABASE.$NOW".log

echo "Beginning Execution of $SCRIPTNAME" >> log/"$LOGFILENAME"

echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.demographic;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.demographic;" >> log/"$LOGFILENAME"


echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.enrollment;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.enrollment;" >> log/"$LOGFILENAME"

echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.death;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.death;" >> log/"$LOGFILENAME"

echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.death_cause;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.death_cause;" >> log/"$LOGFILENAME"

echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.encounter;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.encounter;" >> log/"$LOGFILENAME"

echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.condition;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.condition;" >> log/"$LOGFILENAME"

echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.diagnosis;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.diagnosis;" >> log/"$LOGFILENAME"


echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.procedure;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.procedure;" >> log/"$LOGFILENAME"

echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.dispensing;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.dispensing;" >> log/"$LOGFILENAME"

echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.prescribing;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.prescribing;" >> log/"$LOGFILENAME"

echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.vital;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.vital;" >> log/"$LOGFILENAME"

echo "$EXTRACTDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.lab_result_cm;" >> log/"$LOGFILENAME"
echo "$LOADDBHOSTNAME" >> log/"$LOGFILENAME"
PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"  nohup time psql --host="$LOADDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$VALIDATEDATABASE" -c "select count(1) from pcornet_cdm.lab_result_cm;" >> log/"$LOGFILENAME"
