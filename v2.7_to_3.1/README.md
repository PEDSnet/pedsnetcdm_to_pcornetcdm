## The ETL scripts for PEDSnet CDM v2.5 to PCORnet CDM v3.1 transformation

### Contents 

#### Steps for creating the PCORnet v3.1 data model tables
1. Navigate to transform_map folder, and install the CLI Tool

	 `pip install setup.py`
2.  Run the DDL
	
	 `loading -u <username> -h <hostname> -d <dbname> -s <schemaname> -o ddl`
	 
	 For Full Pipeline:
	 
	 `loading -u <username> -h <hostname> -d <dbname> -s <schemaname> -o pipeline`
	 
	 For ETL Only:
	 
	 `loading -u <username> -h <hostname> -d <dbname> -s <schemaname> -o etl`
	 
	 For Truncating table and removing FK's:
	 
	 `loading -u <username> -h <hostname> -d <dbname> -s <schemaname> -o truncate`
	 
	 For updating the valueset map:
	 
	 `loading -u <username> -h <hostname> -d <dbname> -s <schemaname> -o update_map`
	 
	 For help:
	 `loading --help`


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
7. Create views on start2001 schema tables (./view-creation/func_upper_tbl_name.sql)

### Schema Conventions

- The PEDSnet CDM tables are stored in the `dcc_pedsnet` schema
- The PCORnet v3.1 CDM tables and the OMOP to PCORnet mapping tables are stored in the `dcc_3dot1_pcornet` and `dcc_3dot1_start2001_pcornet` schemas
- The vocbaulary tables are stored in the `vocabulary` schema 
