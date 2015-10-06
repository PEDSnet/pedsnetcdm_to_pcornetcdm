set role pcor_et_user;

truncate table pcornet_cdm.cz_omop_pcornet_concept_map;

CREATE TABLE pcornet_cdm.cz_omop_pcornet_concept_map
(
  target_concept character varying(200),
  source_concept_class character varying(200),
  source_concept_id character varying(200),
  value_as_concept_id bigint,
  concept_description character varying(200)
)
