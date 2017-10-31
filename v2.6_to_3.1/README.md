# The ETL scripts for PEDSnet CDM v2.6 to PCORnet CDM v3.1 transformation

## Contents 



## Steps for creating pcornet_data_model_set_up

1. Navigate to [pcornet_loading](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/pcornet_loading) , and install the CLI Tool

	 `pip install setup.py`
2.  Load the tool and the valuest map 
	
	 `loading -u <username> -h <hostname> -d <dbname> -s <schemaname>`
	 
	* more information about the tool can be found [here](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/pcornet_loading/README.md)

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
7. [Create views](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/view-creation) on start2001 schema tables 

### Schema Conventions

- The PEDSnet CDM tables are stored in the `dcc_pedsnet` schema
- The PCORnet v3.1 CDM tables and the OMOP to PCORnet mapping tables are stored in the `dcc_3dot1_pcornet` and `dcc_3dot1_start2001_pcornet` schemas
- The vocbaulary tables are stored in the `vocabulary` schema 
