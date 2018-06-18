-- Set up the privilege to the user
GRANT ALL ON SCHEMA SITE TO pcor_et_user;
GRANT USAGE ON  SCHEMA SITE TO pcornet_sas;
GRANT ALL ON ALL TABLES IN SCHEMA SITE TO pcor_et_user;
GRANT SELECT ON ALL TABLES IN SCHEMA SITE TO pcornet_sas;
