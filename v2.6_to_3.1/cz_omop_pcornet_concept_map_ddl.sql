CREATE TABLE dcc_3dot1_pcornet.cz_omop_pcornet_concept_map
(
  target_concept character varying(200),
  source_concept_class character varying(200),
  source_concept_id character varying(200),
  value_as_concept_id bigint, 
  concept_description character varying(200)
); 

alter table dcc_3dot1_pcornet.cz_omop_pcornet_concept_map owner to pcor_et_user; 
