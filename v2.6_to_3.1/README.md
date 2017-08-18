# The ETL scripts for PEDSnet CDM v2.5 to PCORnet CDM v3.1 transformation

## Contents 



## Steps for creating the PCORnet v3.1 data model tables
1. Create the schemas 

	```
	create schema dcc_3dot1_pcornet AUTHORIZATION pcor_et_user;
	create schema dcc_3dot1_start2001_pcornet AUTHORIZATION pcor_et_user;
	create schema chop_3dot1_pcornet AUTHORIZATION pcor_et_user;
	create schema chop_3dot1_start2001_pcornet AUTHORIZATION pcor_et_user;
	```

2. Use the [Makefile](create_pcornet_3.1_tables.Makefile) to create the PCORnet 3.1 tables
`make -f create_pcornet_3.1_tables.Makefile DB=pedsnet_dcc_v26 VER=3.1.0`

3. Add the `site` column to various fields using the following alter table commands: 

```
alter table dcc_3dot1_pcornet.demographic add column site character varying not NULL;
alter table dcc_3dot1_pcornet.enrollment add column site character varying not null;
alter table dcc_3dot1_pcornet.death add column site character varying not null;
alter table dcc_3dot1_pcornet.death_cause add column site character varying not null;
alter table dcc_3dot1_pcornet.encounter add column site character varying not null;
alter table dcc_3dot1_pcornet.condition add column site character varying not null;
alter table dcc_3dot1_pcornet.diagnosis add column site character varying not null;
alter table dcc_3dot1_pcornet.procedures add column site character varying not null;
alter table dcc_3dot1_pcornet.dispensing   add column site character varying not null;
alter table dcc_3dot1_pcornet.prescribing   add column site character varying not null;
alter table dcc_3dot1_pcornet.vital   add column site character varying not null;
alter table dcc_3dot1_pcornet.lab_result_cm   add column site character varying not null;

```

```
alter table dcc_3dot1_start2001_pcornet.demographic add column site character varying not NULL;
alter table dcc_3dot1_start2001_pcornet.enrollment add column site character varying not null;
alter table dcc_3dot1_start2001_pcornet.death add column site character varying not null;
alter table dcc_3dot1_start2001_pcornet.death_cause add column site character varying not null;
alter table dcc_3dot1_start2001_pcornet.encounter add column site character varying not null;
alter table dcc_3dot1_start2001_pcornet.condition add column site character varying not null;
alter table dcc_3dot1_start2001_pcornet.diagnosis add column site character varying not null;
alter table dcc_3dot1_start2001_pcornet.procedures add column site character varying not null;
alter table dcc_3dot1_start2001_pcornet.dispensing   add column site character varying not null;
alter table dcc_3dot1_start2001_pcornet.prescribing   add column site character varying not null;
alter table dcc_3dot1_start2001_pcornet.vital   add column site character varying not null;
alter table dcc_3dot1_start2001_pcornet.lab_result_cm   add column site character varying not null;

```
## Steps for generating the transformation valuset map
1. Navigate to transform_map folder, and install the CLI Tool

	 `pip install setup.py`
2.  Load the tool and the valuest map 
	
	 `loading -u <username> -h <hostname> -d <dbname> -s <schemaname>`
	 


## Steps for Executing the ETL Scripts 

1. Execute the ETL scripts in the following order 
    - [Demographic](./ETL%20Scripts/Demographic_ETL.sql)
    - [Enrollment](./ETL%20Scripts/Enrollment_ETL.sql)
    - [Death](./ETL%20Scripts/Death_ETL.sql)
    - [Death Cause](./ETL%20Scripts/Death_Cause_ETL.sql)
    - [Encounter](./ETL%20Scripts/Encounter_ETL.sql)
    - [Condition](./ETL%20Scripts/Condition_ETL.sql)
    - [Diagnosis](./ETL%20Scripts/Diagnosis_ETL.sql)
    - [Procedure](./ETL%20Scripts/Procedure_ETL.sql)
    - [Dispensing](./ETL%20Scripts/Dispensing_ETL.sql)
    - [Prescribing](./ETL%20Scripts/Prescribing_ETL.sql)
    - [Vital](./ETL%20Scripts/Vital_ETL.sql)
    - [Lab\_Result\_CM](./ETL%20Scripts/Lab_Result_CM_ETL.sql)
5. Execute the following add constraints commands

	- [Add foreign keys](FK_statements.sql)
	- [Add indices](index_statements.sql)

6. 	follow steps in [start 2001 readme](./ETL%20Scripts/start2001/README.md)
7. Create views on start2001 schema tables 

### Schema Conventions

- The PEDSnet CDM tables are stored in the `dcc_pedsnet` schema
- The PCORnet v3.1 CDM tables and the OMOP to PCORnet mapping tables are stored in the `dcc_3dot1_pcornet` and `dcc_3dot1_start2001_pcornet` schemas
- The vocbaulary tables are stored in the `vocabulary` schema 
