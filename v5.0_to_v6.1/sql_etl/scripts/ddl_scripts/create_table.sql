CREATE TABLE IF NOT EXISTS pcornet_maps.pedsnet_pcornet_valueset_map (
    source_concept_class character varying(200),
    target_concept character varying(200),
    pcornet_name character varying(200),
    source_concept_id character varying(200),
    concept_description character varying(200),
    value_as_concept_id character varying(200)
);

CREATE TABLE IF NOT EXISTS pcornet_maps.chief_complaint_map (
    observation_source_value character varying(256),
    count integer,
    condition_concept_id bigint,
    condition_concept_name character varying(256),
    concept_code character varying(256),
    vocabulary_id character varying(256),
    pcornet_condition_type character varying(256)
);
