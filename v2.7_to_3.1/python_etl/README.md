# PEDSnet to PCORnet ETL 

## Configuration

### Create Condition Configuration File
Create a configuration file named `p_to_p.yml` using the template specified in p_to\_p\_sample.yml

#### Example

```
db:
 driver             : (postgresql, oracle, mysql, sqlite, or mssql+pyodbc)
 pedsnet_dbname	    : TestDb (Name of Database)
 pcornet_dbname     : TestDb (Name of Database)
 dbuser	            : TestUser
 dbpass	            : TestUserPassword123
 dbhost             : http://testdbhost.com
 dbport	            : 5432
 pedsnet_schema     : pedsnet_domain_schema (Name of schema that holds PEDSnet domain tables)
 pcornet_schema     : pcornet_domain_schema (Name of schema that holds PCORnet domain tables)
reporting:
  site_directory     : ~/Documents/test_directory (Temporary location for output of progress)
```

## PEDSnet to Pcornet ETL Details

The code's "main" function is in workflow.py. There is a class for every PCORnet table and one for the pedsnet_pcornet_valueset_map table. There is an ETL file for each PCORnet table named \<table>ETL.py.

### ETL Process

1. It is expected that the schemas and tables exist.
1. The configuration file `p_to_p.yml` read and the database connection established.
1. SQLAlchemy engines for PEDSnet and PCORnet set up.
1. SQLAlchemy is used to load the data from the PCORnet table.
1. Blaze Odo is used to transform the column names and data types.
1. SQLAlchemy is used to load the data to the PCORnet table.
1. To Do:
	1. 	Automate process to run in background
	1. Provide output to monitor progress


