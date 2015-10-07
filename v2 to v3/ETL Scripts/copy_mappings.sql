set search_path to pcornet_cdm,public;
\copy pcornet_cdm.cz_omop_pcornet_concept_map from 'pedsnet_pcornet_mappings.txt' with (format text, delimiter '|', null 'NULL');

