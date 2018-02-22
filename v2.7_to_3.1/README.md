## The ETL scripts for PEDSnet CDM v2.7 to PCORnet CDM v3.1 transformation

## Contents 

### [Documentation - Extraction from PEDSnet to PCORnet CDM](./doc/extraction/)
This directory contains all details source and destination of the values for the PEDSnet to PCORnet. The extraction documents is available for all the tables that are in the PCORnet CDM.

### [ETL Scripts/tablename_ETL.sql](./sql_etl/scripts/etl_scripts/)
This directory contains the ETL source code, i.e. table-wise SQL queries to extract the PCORnet instance from a given PEDSnet CDM instance and the source-to-concept mapping table.

### [sql_etl](./sql_etl)
This directory contains the source code for python tool to create setup for the PCORnet ETL, i.e. Create the DDL,  populating concept Map and harvest tables.

### [view-creation](./sql_etl/scripts/view-creation/)
This directory contains the sql script for creating the upper case views for the table names. These view are necessary for running the PCORnet Data Curation query.

### [pedsnet_pcornet_valueset_map](./sql_etl/data/)
The pedsnet_pcornet_valueset_map consist of all the values that are required for mapping the data from PEDSnet CDM to PCORnet CDM. This data can be found in the pcornet_loading derictory.

### Other SQL Scripts

  ##### [Truncate all](./sql_etl/scripts/reset_tables_scripts/)
After making changes in the scripts. To test the scripts re-run of ETL is require. This script can be use to preseve the ddl for the re-run of the ETL. This script will truncate all the tables and remove all foregin constraints on the table.

 #### [Create valueset map](./pcornet_loading/scripts/ddl_scripts/)
   If not using the pcornet_loading tool to create the DDL, this script can be use to create the pedsnet to pcornet valueset table. 


## Steps for creating the PCORnet v3.1 data model tables

1. Navigate to [sql_etl](./sql_etl) folder, and install the CLI Tool

	 To install the CLI Tool

	  activate the virtual environment using following command
	
	`virtualenv venv`
	
	`. venv\bin\activate`
	
   install the tool
	
	 `pip install -r requirements.txt`
	 
	 `pip install --editable .`
	 
2.  Select form the following option:
	
	 For DDL:
	
	 `loading -u <username> -h <hostname> -d <dbname> -s <schemaname> -o <option>`
	 
	 option :
	  1. pipeline&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp; Run the full PCORnet pipeline
	  2. ddl&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp; Only the DDL or initial setup for the PEDSnet to PCORnet CDM
	  3. etl&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp; Runs only the ETL on the PEDSnet data.
	  4. truncate&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;Re-run of the ETL use this option to truncate all tables and remove Foregin Key constraints
	  5. update_map -&nbsp; Adding or updating new values in the concept map table.
	 
	 For [help](./sql_etl/README.md):
	 
	 `loading --help`


## Steps for Executing the ETL Scripts 

1. Execute the ETL scripts in the following order 
    - [Demographic](./sql_etl/scripts/etl_scripts/a_demographic.sql)
    - [Enrollment](./sql_etl/scripts/etl_scripts/b_enrollment.sql)
    - [Death](./sql_etl/scripts/etl_scripts/c_death.sql)
    - [Death Cause](./sql_etl/scripts/etl_scripts/d_death_Cause.sql)
    - [Encounter](./sql_etl/scripts/etl_scripts/e_encounter.sql)
    - [Condition](./sql_etl/scripts/etl_scripts/f_condition.sql)
    - [Diagnosis](./sql_etl/scripts/etl_scripts/f_diagnosis.sql)
    - [Procedure](./sql_etl/scripts/etl_scripts/g_procedure.sql)
    - [Dispensing](./sql_etl/scripts/etl_scripts/h_dispensing.sql)
    - [Prescribing](./sql_etl/scripts/etl_scripts/i_prescribing.sql)
    - [Vital](./sql_etl/scripts/etl_scripts/j_vital_ETL.sql)
    - [Lab\_Result\_CM](./sql_etl/scripts/etl_scripts/k_lab_result_cm.sql)
    
5. Execute the following add constraints commands

	- [Add foreign keys](./sql_etl/scripts/etl_scripts/l_fk.sql)
	
	- [Add indices](./sql_etl/scripts/etl_scripts/m_index_statements.sql)

6. 	follow steps in [start 2001 readme](./sql_etl/scripts/etl_scripts/)
7. [Create views](./sql_etl/scripts/view-creation/) on start2001 schema tables 

### Schema Conventions

- The PEDSnet CDM tables are stored in the `dcc_pedsnet` schema
- The PCORnet v3.1 CDM tables and the OMOP to PCORnet mapping tables are stored in the `dcc_3dot1_pcornet` and `dcc_3dot1_start2001_pcornet` schemas
- The vocbaulary tables are stored in the `vocabulary` schema 
