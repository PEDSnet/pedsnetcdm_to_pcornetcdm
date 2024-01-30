
## PEDSnet To PCORnet ETL 
- The pedsnetcdm_to_pcornetcdm repository is no longer updated with newer PEDSnet/PCORnet versions as of October 2023 (PEDSnet 5.1 to PCORnet 6.1) and thus this should be considered historical code.
- The PEDSnet_to_PCORnet_ETL has been migrated to an Apache Airflow Deployment to parallelize the running of scripts and thus improve runtime.
- The Airflow PEDSnet_to_PCORnet_ETL instance has the most up-to-date PEDSnet/PCORnet version transformation. [Repository is here](https://github.com/PEDSnet/airflow_dag/tree/ops04/dags/PEDSnet_to_PCORnet_ETL).
