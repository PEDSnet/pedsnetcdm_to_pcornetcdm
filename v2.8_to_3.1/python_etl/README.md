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

There is a class for every PCORnet table and one for the pedsnet_pcornet_valueset_map table. There is an ETL file for each PCORnet table named \<table>ETL.py.

### ETL Process

1. It is expected that the schemas and tables exist.
1. The configuration file `p_to_p.yml` read and the database connection established.
1. SQLAlchemy engines for PEDSnet and PCORnet set up.
1. SQLAlchemy is used to load the data from the PCORnet table.
1. Blaze Odo is used to transform the column names and data types.
1. SQLAlchemy is used to load the data to the PCORnet table.

### Using PEDSnet to Pcornet ETL

#### Installation
	Expects that Docker is installed
	After cloning the repo:

    Create /python_etl/ptop/apps/runit/management/commands/p_to_p.yml using p_to_p_sample.yml as a guide
    
    Build and start the app from the python_etl directory:

       docker-compose up
       # Or to rebuild
       docker-compose up --build

       # migrate and collectstatic
       docker-compose run app init

       # create admin user
       docker-compose run app manage createsuperuser
        	
       migrate and collectstatic and create admin user only need to be done once unless the rebuild option is used
        	
#### Run the PEDSnet to Pcornet ETL steps
	Use the web interface at http:/ip_address/ptop
	view the results at http:/ip_address/admin
	(login using super user created during install)
	
    OR 
    
    Run PEDSnet to Pcornet at command line
    docker-compose run app manage <command to run>
    
    available commands are demographicsETL and enrollmentETL, more coming soon


#### Other helpful commands
	**Run these commands from the python_etl directory**

    # enter db where results are stored
    docker-compose run app manage dbshell

    # run any management command
    docker-compose run app manage <command and options>

    # enter bash shell
    docker-compose run app /bin/bash

    # stop everything
    docker-compose stop

    # stop everything, destroy containers, and volumes
    docker-compose down

#### Development

	Files are located in /python_etl/ptop/apps/runit/management/commands/
	
	To add background task modify /python_etl/ptop/apps/runit/tasks.py
	
	To add new ETL step to webpage modify /python_etl/ptop/apps/runit/views.py
	