CREATE TABLE IF NOT EXISTS stlouis_start2017_pcornet.pedsnet_pcornet_valueset_map (
                target_concept character varying(200),
                source_concept_class character varying(200),
                source_concept_id character varying(200),
                value_as_concept_id character varying(200),
                concept_description character varying(200)
                );

                ALTER TABLE stlouis_start2017_pcornet.pedsnet_pcornet_valueset_map
                OWNER to pcor_et_user;

                GRANT SELECT ON TABLE stlouis_start2017_pcornet.pedsnet_pcornet_valueset_map TO pcornet_sas;

                GRANT SELECT ON TABLE stlouis_start2017_pcornet.pedsnet_pcornet_valueset_map TO peds_staff;

                GRANT ALL ON TABLE stlouis_start2017_pcornet.pedsnet_pcornet_valueset_map TO pcor_et_user;

                GRANT ALL ON TABLE stlouis_start2017_pcornet.pedsnet_pcornet_valueset_map TO dcc_owner; 