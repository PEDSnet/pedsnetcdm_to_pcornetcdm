begin;

ALTER TABLE SITE_pcornet.death_cause ADD CONSTRAINT xpk_death_cause PRIMARY KEY (patid, death_cause, death_cause_code, death_cause_type, death_cause_source);

ALTER TABLE SITE_pcornet.demographic ADD CONSTRAINT xpk_demographic PRIMARY KEY (patid);

ALTER TABLE SITE_pcornet.diagnosis add CONSTRAINT xpk_diagnosis PRIMARY KEY (diagnosisid);

ALTER TABLE SITE_pcornet.dispensing add CONSTRAINT xpk_dispensing PRIMARY KEY (dispensingid);

-- ALTER TABLE SITE_pcornet.encounter add CONSTRAINT xpk_encounter PRIMARY KEY (encounterid);

ALTER TABLE SITE_pcornet.enrollment add CONSTRAINT xpk_enrollment PRIMARY KEY (patid, enr_start_date, enr_basis);

ALTER TABLE SITE_pcornet.lab_result_cm add CONSTRAINT xpk_lab_result_cm PRIMARY KEY (lab_result_cm_id);

ALTER TABLE SITE_pcornet.prescribing add CONSTRAINT xpk_prescribing PRIMARY KEY (prescribingid);

ALTER TABLE SITE_pcornet.procedures add CONSTRAINT xpk_procedures PRIMARY KEY (proceduresid);

ALTER TABLE SITE_pcornet.death add CONSTRAINT xpk_death PRIMARY KEY (patid, death_source);

ALTER TABLE SITE_pcornet.condition add CONSTRAINT xpk_condition PRIMARY KEY (conditionid);

ALTER TABLE SITE_pcornet.encounter ADD CONSTRAINT enc_fk FOREIGN KEY ( patid ) REFERENCES SITE_pcornet.demographic (patid);

ALTER TABLE SITE_pcornet.condition ADD CONSTRAINT cond_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_pcornet.demographic (patid);

ALTER TABLE SITE_pcornet.condition ADD CONSTRAINT cond_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_pcornet.encounter (encounterid);

ALTER TABLE SITE_pcornet.diagnosis ADD CONSTRAINT diag_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_pcornet.demographic (patid);

ALTER TABLE SITE_pcornet.diagnosis ADD CONSTRAINT diag_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_pcornet.encounter (encounterid);


ALTER TABLE SITE_pcornet.procedures ADD CONSTRAINT proc_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_pcornet.demographic (patid);

ALTER TABLE SITE_pcornet.procedures ADD CONSTRAINT proc_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_pcornet.encounter (encounterid);

ALTER TABLE SITE_pcornet.dispensing ADD CONSTRAINT disp_fk FOREIGN KEY ( patid ) REFERENCES SITE_pcornet.demographic (patid);

ALTER TABLE SITE_pcornet.prescribing ADD CONSTRAINT pres_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_pcornet.demographic (patid);


ALTER TABLE SITE_pcornet.prescribing ADD CONSTRAINT pres_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_pcornet.encounter (encounterid);

ALTER TABLE SITE_pcornet.vital ADD CONSTRAINT vital_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_pcornet.demographic (patid);

ALTER TABLE SITE_pcornet.vital ADD CONSTRAINT vital_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_pcornet.encounter (encounterid);


ALTER TABLE SITE_pcornet.lab_result_cm ADD CONSTRAINT lab_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_pcornet.demographic (patid);

ALTER TABLE SITE_pcornet.lab_result_cm ADD CONSTRAINT lab_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_pcornet.encounter (encounterid);

commit;