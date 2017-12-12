-- Set up the privilege to the user
GRANT ALL ON SCHEMA nationwide_3dot1_start2001_pcornet TO pcor_et_user;
GRANT USAGE ON  SCHEMA nationwide_3dot1_start2001_pcornet TO pcornet_sas;
GRANT ALL ON ALL TABLES IN SCHEMA nationwide_3dot1_start2001_pcornet TO pcor_et_user;
GRANT SELECT ON ALL TABLES IN SCHEMA nationwide_3dot1_start2001_pcornet TO pcornet_sas;
