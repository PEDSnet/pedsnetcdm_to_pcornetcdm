#The ETL scripts for PEDSnet CDM V2 to PCORnet CDM V3 transformation

## Contents 
###pedsnet_pcornet_mappings.xls

This document contains the mappings from PEDSnet vocabulary to PCORnet vocabulary. Each column in this file denotes the following:

- Source_Concept_Class: Concept class in the OMOP vocabulary (refers to the name of a field in PCORnet model that needs to be encoded into the PCORnet vocabulary)
- PCORNET_Concept: value as represented in the PCORnet vocabulary
- Standard_Concept_ID: concept_id in the OMOP vocabulary (this columns refers to the observation_concept_id field of the Observation table, in case of PCORnet fields that are recorded as observations in the OMOP model)
- Value_as_concept: value_as_concept_id field in the the Observation table in PEDsnet (only applicable for fields that are recorded as observations in the PEDSnet CDM)
- Concept_Description: Natural language description of the value

###pedsnet_pcornet_mappings.txt

This document is a text version of the pedsnet_pcornet_mappings.xls file. The fields are pipe-delimited.


### ETL Scripts/cz\_omop\_pcornet\_concept\_map\_ddl.sql
This document contains the DDL script to create the source-to-concept mapping table (i.e. PEDSnet->PCORnet vocabulary mapping) into database. 

### ETL Scripts/tablename_ETL.sql
This file contains the ETL source code, i.e. table-wise SQL queries to extract the PCORnet instance from a given PEDSnet CDM instance and the source-to-concept mapping table. 

## Steps for Executing the Scripts 
1. Execute the [PCORnet Schema DDL](http://dmsa.a0b.io/pcornet/3.0.0/) into the pcornet_cdm schema
2. Execute the [Mapping table DDL] (./ETL%20Scripts/cz_omop_pcornet_concept_map_ddl.sql) 
3. Populate the mapping table created in Step 2 by importing the [pedsnet\_pcornet\_mappings.txt file] (../pedsnet_pcornet_mappings.txt). The setting for import in PostgreSQL include, format=text, delimiter=|, NULL String=NULL.
4. Execute the ETL scripts in the following order 
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
