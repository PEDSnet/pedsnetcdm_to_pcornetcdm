-- Set up the privilege to the user
GRANT ALL ON SCHEMA nemours_pcornet TO pcor_et_user;
GRANT USAGE ON  SCHEMA nemours_pcornet TO pcornet_sas;
GRANT ALL ON ALL TABLES IN SCHEMA nemours_pcornet TO pcor_et_user;
GRANT SELECT ON ALL TABLES IN SCHEMA nemours_pcornet TO pcornet_sas;
