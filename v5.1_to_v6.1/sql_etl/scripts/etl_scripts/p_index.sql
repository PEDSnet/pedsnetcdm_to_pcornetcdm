begin;

INSERT INTO SITE_pcornet.version_history (operation, model, model_version, dms_version, dmsa_version) VALUES ('create indexes', 'pcornet', '6.1.0', '1.0.3-alpha', '0.6.1');

CREATE INDEX idx_enrol_patid ON SITE_pcornet.enrollment (patid);

CREATE INDEX idx_death_patid ON SITE_pcornet.death (patid);

CREATE INDEX idx_death_cause_patid ON SITE_pcornet.death_cause (patid);

CREATE INDEX idx_encounter_patid ON SITE_pcornet.encounter (patid);

CREATE INDEX idx_encounter_enctype ON SITE_pcornet.encounter (enc_type);

-- CREATE INDEX idx_cond_encid ON SITE_pcornet.condition (encounterid);

CREATE INDEX idx_cond_patid ON SITE_pcornet.condition (patid);

CREATE INDEX idx_condition_ccode ON SITE_pcornet.condition (condition);

CREATE INDEX idx_diag_patid ON SITE_pcornet.diagnosis (patid);

CREATE INDEX idx_diag_encid ON SITE_pcornet.diagnosis (encounterid);

CREATE INDEX idx_diag_code ON SITE_pcornet.diagnosis (dx);

CREATE INDEX idx_proc_encid ON SITE_pcornet.procedures (encounterid);

CREATE INDEX idx_proc_patid ON SITE_pcornet.procedures (patid);

CREATE INDEX idx_proc_px ON SITE_pcornet.procedures (px);

CREATE INDEX idx_disp_patid ON SITE_pcornet.dispensing (patid);

CREATE INDEX idx_disp_ndc ON SITE_pcornet.dispensing (ndc);

--CREATE INDEX idx_pres_encid ON SITE_pcornet.prescribing (encounterid);

CREATE INDEX idx_pres_patid ON SITE_pcornet.prescribing (patid);

CREATE INDEX idx_pres_rxnorm ON SITE_pcornet.prescribing (rxnorm_cui);

CREATE INDEX idx_vital_patid ON SITE_pcornet.vital (patid);

CREATE INDEX idx_vital_encid ON SITE_pcornet.vital (encounterid);

CREATE INDEX idx_lab_patid ON SITE_pcornet.lab_result_cm (patid);

CREATE INDEX idx_lab_encid ON SITE_pcornet.lab_result_cm (encounterid);

CREATE INDEX idx_loinc_encid ON SITE_pcornet.lab_result_cm (lab_loinc);

CREATE INDEX idx_med_patid ON SITE_pcornet.med_admin (patid);

CREATE INDEX idx_med_encid ON SITE_pcornet.med_admin (encounterid);

CREATE INDEX idx_obsclin_patid ON SITE_pcornet.obs_clin(patid);

CREATE INDEX idx_obsclin_encid ON SITE_pcornet.obs_clin(encounterid);

CREATE INDEX idx_obsgen_patid ON SITE_pcornet.obs_gen (patid);

CREATE INDEX idx_obsgen_encid ON SITE_pcornet.obs_gen (encounterid);

CREATE INDEX idx_geocode_addr ON SITE_pcornet.private_address_geocode (addressid);

CREATE INDEX idx_procm_patid ON SITE_pcornet.pro_cm (patid);

commit;
