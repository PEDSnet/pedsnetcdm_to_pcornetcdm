CREATE INDEX idx_enrol_patid ON SITE_3dot1_start2001_pcornet.enrollment (patid);

CREATE INDEX idx_death_patid ON SITE_3dot1_start2001_pcornet.death (patid);

CREATE INDEX idx_death_cause_patid ON SITE_3dot1_start2001_pcornet.death_cause (patid);

CREATE INDEX idx_encounter_patid ON SITE_3dot1_start2001_pcornet.encounter (patid);

CREATE INDEX idx_encounter_enctype ON SITE_3dot1_start2001_pcornet.encounter (enc_type);

CREATE INDEX idx_cond_patid ON SITE_3dot1_start2001_pcornet.condition (patid);

CREATE INDEX idx_condition_ccode ON SITE_3dot1_start2001_pcornet.condition (condition);

CREATE INDEX idx_diag_patid ON SITE_3dot1_start2001_pcornet.diagnosis (patid);

CREATE INDEX idx_diag_encid ON SITE_3dot1_start2001_pcornet.diagnosis (encounterid);

CREATE INDEX idx_diag_code ON SITE_3dot1_start2001_pcornet.diagnosis (dx);


CREATE INDEX idx_proc_patid ON SITE_3dot1_start2001_pcornet.procedures (patid);

CREATE INDEX idx_proc_px ON SITE_3dot1_start2001_pcornet.procedures (px);

CREATE INDEX idx_disp_patid ON SITE_3dot1_start2001_pcornet.dispensing (patid);

CREATE INDEX idx_disp_ndc ON SITE_3dot1_start2001_pcornet.dispensing (ndc);

CREATE INDEX idx_pres_patid ON SITE_3dot1_start2001_pcornet.prescribing (patid);

CREATE INDEX idx_pres_rxnorm ON SITE_3dot1_start2001_pcornet.prescribing (rxnorm_cui);

CREATE INDEX idx_vital_patid ON SITE_3dot1_start2001_pcornet.vital (patid);

CREATE INDEX idx_vital_encid ON SITE_3dot1_start2001_pcornet.vital (encounterid);

CREATE INDEX idx_lab_patid ON SITE_3dot1_start2001_pcornet.lab_result_cm (patid);

CREATE INDEX idx_lab_encid ON SITE_3dot1_start2001_pcornet.lab_result_cm (encounterid);

CREATE INDEX idx_loinc_encid ON SITE_3dot1_start2001_pcornet.lab_result_cm (lab_loinc);