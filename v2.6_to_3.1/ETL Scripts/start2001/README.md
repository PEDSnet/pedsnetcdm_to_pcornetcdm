#Steps to create the start2001 extract 


## Steps for Executing the ETL Scripts 
1. Execute the DDL [visit_person_map](create_patient_visit_start2001.sql)
2. Execute the ETL scripts in the following order 
    - [Demographic](./ETL%20Scripts/start2001/Demographic_ETL.sql)
    - [Enrollment](./ETL%20Scripts/start2001/Enrollment_ETL.sql)
    - [Death](./ETL%20Scripts/start2001/Death_ETL.sql)
    - [Death Cause](./ETL%20Scripts/start2001/Death_Cause_ETL.sql)
    - [Encounter](./ETL%20Scripts/start2001/Encounter_ETL.sql)
    - [Condition](./ETL%20Scripts/start2001/Condition_ETL.sql)
    - [Diagnosis](./ETL%20Scripts/start2001/Diagnosis_ETL.sql)
    - [Procedure](./ETL%20Scripts/start2001/Procedure_ETL.sql)
    - [Dispensing](./ETL%20Scripts/start2001/Dispensing_ETL.sql)
    - [Prescribing](./ETL%20Scripts/start2001/Prescribing_ETL.sql)
    - [Vital](./ETL%20Scripts/start2001/Vital_ETL.sql)
    - [Lab\_Result\_CM](./ETL%20Scripts/start2001/Lab_Result_CM_ETL.sql)
3. Execute the following add constraints commands

	- [Add foreign keys](FK_statements.sql)
	- [Add indices](index_statements.sql)

