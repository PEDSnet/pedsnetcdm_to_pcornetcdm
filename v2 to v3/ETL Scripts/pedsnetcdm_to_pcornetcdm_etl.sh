#!/bin/bash

export SCRIPTNAME="pcornetcdm_ddl.sql"      && echo "Beginning Execution of $SCRIPTNAME" > log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="cz_omop_pcornet_concept_map_ddl.sql"      && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="copy_mappings.sql"       && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Demographic_ETL.sql"     && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Enrollment_ETL.sql"      && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Death_ETL.sql"           && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Death_Cause_ETL.sql"     && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Encounter_ETL.sql"       && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Condition_ETL.sql"       && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Diagnosis_ETL.sql"       && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Procedure_ETL.sql"       && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Dispensing_ETL.sql"      && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Prescribing_ETL.sql"     && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Vital_ETL.sql"           && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Lab_Result_CM_ETL.sql"   && echo "Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

#PGPASSWORD=$ETL_DATABASE_USER_PASSWORD nohup time psql  --host localhost --user $ETL_DATABASE_USER   $DATABASE < PCORnet_CDM_V1_pgsql.ddl > log/"$DATABASE"_PCORnet_CDM_V1_pgsql.ddl.log
