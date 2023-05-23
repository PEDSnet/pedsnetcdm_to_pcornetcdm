-- Set up the privilege to the user
GRANT ALL ON SCHEMA pcornet_maps TO pcor_et_user;
-- GRANT USAGE ON  SCHEMA pcornet_maps TO pcornet_sas;
GRANT ALL ON ALL TABLES IN SCHEMA pcornet_maps TO pcor_et_user;
-- GRANT SELECT ON ALL TABLES IN SCHEMA pcornet_maps TO pcornet_sas;
