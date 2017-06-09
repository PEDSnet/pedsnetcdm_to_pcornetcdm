# The ETL scripts for PEDSnet CDM v2.5 to PCORnet CDM v3.1 transformation

## Contents 
### pedsnet_pcornet_mappings.xls

This document contains the mappings from PEDSnet vocabulary to PCORnet vocabulary. Each column in this file denotes the following:

- Source_Concept_Class: Concept class in the OMOP vocabulary (refers to the name of a field in PCORnet model that needs to be encoded into the PCORnet vocabulary)
- PCORNET_Concept: value as represented in the PCORnet vocabulary
- Standard_Concept_ID: concept_id in the OMOP vocabulary (this columns refers to the observation_concept_id field of the Observation table, in case of PCORnet fields that are recorded as observations in the OMOP model)
- Value_as_concept: value_as_concept_id field in the the Observation table in PEDsnet (only applicable for fields that are recorded as observations in the PEDSnet CDM)
- Concept_Description: Natural language description of the value

### pedsnet_pcornet_mappings.txt

This document is a text version of the pedsnet_pcornet_mappings.xls file. The fields are pipe-delimited.


### ETL Scripts/cz\_omop\_pcornet\_concept\_map\_ddl.sql
This document contains the DDL script to create the source-to-concept mapping table (i.e. PEDSnet->PCORnet vocabulary mapping) into database. 

### ETL Scripts/tablename_ETL.sql
This file contains the ETL source code, i.e. table-wise SQL queries to extract the PCORnet instance from a given PEDSnet CDM instance and the source-to-concept mapping table. 

## Steps for creating the PCORnet v3.1 data model 
1. Use the [Makefile] (create_pcornet_3.1_tables.Makefile) to create the PCORnet 3.1 tables
`make -f create_pcornet_tables.Makefile DB=pedsnet_dcc_v25 VER=3.1.0`

2. Add the `site` column to various fields using the following alter table commands: 

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
## Steps for Executing the ETL Scripts 
1. Execute the [Mapping table DDL] (./ETL%20Scripts/cz_omop_pcornet_concept_map_ddl.sql) 
2. Populate the mapping table created in Step 2 by importing the [pedsnet\_pcornet\_mappings.txt file] (../pedsnet_pcornet_mappings.txt). The setting for import in PostgreSQL include, format=text, delimiter=|, NULL String=NULL.
3. Execute the ETL scripts in the following order 
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
4. Execute the following add constraints commands

	- [Add foreign keys](FK_statements.sql)
	- [Add indices](index_statements.sql)

### Schema Conventions

- The PEDSnet CDM tables are stored in the `dcc_pedsnet` schema
- The PCORnet v3.1 CDM tables and the OMOP to PCORnet mapping tables are stored in the `dcc_3dot1_pcornet` and `dcc_3dot1_start2001_pcornet` schemas
- The vocbaulary tables are stored in the `vocabulary` schema 
