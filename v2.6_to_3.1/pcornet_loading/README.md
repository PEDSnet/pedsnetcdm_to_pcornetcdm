# `pcornet_loading`

pcornet_loading is a python based CLI too that is used to automate the process of creating the DDL for PCORnet ETL.

# What problem it solves

#### This tools performs all the below mention steps that are required for PCORnet DDL.
1. Create the schemas 

	```
	create schema dcc_3dot1_pcornet AUTHORIZATION pcor_et_user;
	create schema dcc_3dot1_start2001_pcornet AUTHORIZATION pcor_et_user;
	```

2. Creates the PCORnet 3.1 tables

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
4. Alter and/ grant permission to ETL user and the SaS users

5. Create the valuset table require to map the PEDSnet values to PCORnet

6. Populate the `pedsnet_pcornet_valueset_map`

7. Populate the `harvest` table

# Dependancies

## Python 

`pcornet_loading` is a python based tool. It is built under the virtual environment. This tool uses python click library for building
CLI tool. The set up tool make it easy to install. 

# Building and Running the tool

1. Navigate to [pcornet_loading](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/master/v2.6_to_3.1/pcornet_loading) folder, and download the tool.

2. To install the CLI Tool

	 `pip install setup.py`
   
3.  Load the tool and the valuest map 
	
	 `loading -u <username> -h <hostname> -d <dbname> -s <schemaname>`
   
   where the dbname is the name of the database which contains the PEDSnet schema that we want to Transform.
         schemaname is the name of the schema that is to be transformed
         
# Known issue
This tool as of now only work for PostgreSQL database. We are planning to make it compatible and more generic.
