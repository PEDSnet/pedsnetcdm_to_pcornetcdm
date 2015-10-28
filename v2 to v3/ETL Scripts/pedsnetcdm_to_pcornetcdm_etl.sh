#!/bin/bash

export SCRIPTNAME=$0  && export NOW=`date +%Y%m%d%H%M%S`  && echo "$NOW:  $SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="pcornetcdm_ddl.sql"    && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="cz_omop_pcornet_concept_map_ddl.sql"  && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD" nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="copy_mappings.sql"     && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Demographic_ETL.sql"   && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Enrollment_ETL.sql"    && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Death_ETL.sql"         && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Death_Cause_ETL.sql"   && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Encounter_ETL.sql"     && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Condition_ETL.sql"     && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Diagnosis_ETL.sql"     && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Procedure_ETL.sql"     && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Dispensing_ETL.sql"    && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Prescribing_ETL.sql"   && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Vital_ETL.sql"         && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log

export SCRIPTNAME="Lab_Result_CM_ETL.sql" && export NOW=`date +%Y%m%d%H%M%S`    && echo "$NOW:  Beginning Execution of $SCRIPTNAME" >> log/"$DATABASE"_etl.log && PGPASSWORD="$ETL_DATABASE_USER_PASSWORD"   nohup time psql --host="$EXTRACTDBHOSTNAME"   --user="$ETL_DATABASE_USER"  --dbname="$DATABASE" < "$SCRIPTNAME" >> log/"$DATABASE"_etl.log
