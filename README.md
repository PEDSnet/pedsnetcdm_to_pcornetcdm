![version](https://img.shields.io/badge/PCORnetversion-6.0-blue)
![version](https://img.shields.io/badge/PEDSnetversion-4.5-orange)
[![](https://img.shields.io/badge/python-3.4+-blue.svg)](https://www.python.org/downloads/) 
[![](https://img.shields.io/badge/PostgreSQL-13.4+-blue.svg)](https://www.postgresql.org/downloads/)
[![](https://img.shields.io/badge/Datavant-3.5+-blue.svg)](https://datavant.com)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/graphs/commit-activity)




## PEDSnet To PCORnet Transform Process
![](./doc/pedsnet_pcornet_operations.jpg)

## Version
The master branch may contain changes that do not apply to the latest released PEDSnet version. Always refer to one of the official releases. For convenience, the DCC will maintain an up-to-date list of release branch links here:

PCORnet Cycle [![ETL Scripts](https://img.shields.io/badge/ETLScripts--<COLOR>.svg)](https://shields.io/)| Scheduled Refresh | PEDSnet CDM version [![ETL Scripts](https://img.shields.io/badge/docs--<COLOR>.svg)](https://shields.io/) |PCORNet CDM version [![ETL Scripts](https://img.shields.io/badge/docs--<COLOR>.svg)](https://shields.io/)|
:--------:|:-----------: | :----: | :---: | 
[Cycle 11](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v4.5_to_v6.0)| Second Refresh |[4.5](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v4.5.0_1/) |6.0 | 
[Cycle 11](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v4.4_to_v6.0)| First Refresh |[4.4](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v4.4.0_1/) |6.0 | 
[Cycle 10](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v4.3_to_v6.0)| Second Refresh |[4.3](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v4.3.0_1/) |6.0 | 
[Cycle 10](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v4.2_to_v6.0) | First Refresh |[4.2](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v4.2.0_1/) |6.0 | 
[Cycle 9](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v4.1_to_v6.0) | Second Refresh |[4.1](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v4.1.0_1/) |6.0 | 
[Cycle 9](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v4.0_to_v6.0) | First Refresh |[4.0](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v4.0.0_1/) |6.0 | 
[Cycle 8](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v3.9_to_v5.1)|Third Refresh |[3.9](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v3.9.0_1/) |[5.1](https://pcornet.org/wp-content/uploads/2019/09/PCORnet-Common-Data-Model-v51-2019_09_12.pdf)|
[Cycle 8](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v3.8_to_v5.1)|Second Refresh |[3.8](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v3.8.0_1/) |[5.1](https://pcornet.org/wp-content/uploads/2019/09/PCORnet-Common-Data-Model-v51-2019_09_12.pdf)|
[Cycle 8](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v3.7_to_v5.1)|First Refresh |[3.7](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v3.7.0_1/) |[5.1](https://pcornet.org/wp-content/uploads/2019/09/PCORnet-Common-Data-Model-v51-2019_09_12.pdf)|
[Cycle 7](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v3.6_to_v5.1)|Second Refresh |[3.6](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v3.6.0_1/) |[5.1](https://pcornet.org/wp-content/uploads/2019/09/PCORnet-Common-Data-Model-v51-2019_09_12.pdf)|
[Cycle 7](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v3.5_to_v5.1)|First Refresh |[3.5](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v3.5.0_1/) |[5.1](https://pcornet.org/wp-content/uploads/2019/09/PCORnet-Common-Data-Model-v51-2019_09_12.pdf)|
[Cycle 7](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v3.4_to_v5.0)|Initial Refresh |[3.4](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v3.4.0_1/) |5.0|
[Cycle 6](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v3.3_to_v4.1)|Third Refresh |[3.3](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v3.3.0_1/) |4.1|
[Cycle 6](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v3.2_to_v4.1)|Second Refresh |[3.2](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v3.2.0_1/) |4.1|
[Cycle 6](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v3.1_to_v4.1)|First Refresh |[3.1](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v3.1.0_1/) |4.1|
[Cycle 6](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v3.0_to_v4.1)|Initial Refresh |[3.0](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v3.0.0_1/) |4.1|
[Cycle 5](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v2.9_to_v4.1)|Third Refresh |[2.9](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v2.9.0_1/) |4.1|
[Cycle 5](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v2.8_to_v4.0)|Second Refresh |[2.8](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v2.8.0_1/) |4.0|
[Cycle 5](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v2.7_to_v3.1)|First Refresh |[2.7](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v2.7.0_1/) |3.1|
[Cycle 5](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v2.6_to_v3.1)|Initial Refresh |[2.6](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v2.6.0_1/) |3.1|
[Cycle 4](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v2.5_to_v3.1)|Third Refresh |[2.5](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v2.5.0_1/) |3.1|
[Cycle 4](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v2_to_v3.1)|Second Refresh |[2.4](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v2.4.0_1/) |3.1|
[Cycle 4](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v2_to_v3)|First Refresh |[2.3](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v2.3.0_1/) |3.1|
[Cycle 4](https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm/tree/v1_to_v1)|Initial Refresh |[2.2](https://github.com/PEDSnet/Data_Models/tree/pedsnet_v2.2.0_1/) |1.1|
