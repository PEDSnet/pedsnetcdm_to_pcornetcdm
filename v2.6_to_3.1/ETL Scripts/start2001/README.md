#Steps to create the start2001 extract 


## Steps for Executing the ETL Scripts 
1. Execute the DDL [visit_person_map](create_patient_visit_start2001.sql)
2. Execute the ETL scripts in the following order 
    - [Demographic](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Demographic_ETL.sql)
    - [Enrollment](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Enrollment_ETL.sql)
    - [Death](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Death_ETL.sql)
    - [Death Cause](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Death_Cause_ETL.sql)
    - [Encounter](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Encounter_ETL.sql)
    - [Condition](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Condition_ETL.sql)
    - [Diagnosis](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Diagnosis_ETL.sql)
    - [Procedure](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Procedure_ETL.sql)
    - [Dispensing](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Dispensing_ETL.sql)
    - [Prescribing](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Prescribing_ETL.sql)
    - [Vital](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Vital_ETL.sql)
    - [Lab\_Result\_CM](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/ETL%20Scripts/start2001/Lab_Result_CM_ETL.sql)
3. Execute the following add constraints commands

	- [Add foreign keys](FK_statements.sql)
	- [Add indices](index_statements.sql)
4. Populate data in the Harvest Table
