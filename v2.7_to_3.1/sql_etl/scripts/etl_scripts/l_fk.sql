begin;
ALTER TABLE SITE_3dot1_pcornet.encounter ADD CONSTRAINT enc_fk FOREIGN KEY ( patid ) REFERENCES SITE_3dot1_pcornet.demographic (patid);

ALTER TABLE SITE_3dot1_pcornet.condition ADD CONSTRAINT cond_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_3dot1_pcornet.demographic (patid);

ALTER TABLE SITE_3dot1_pcornet.condition ADD CONSTRAINT cond_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_3dot1_pcornet.encounter (encounterid);

ALTER TABLE SITE_3dot1_pcornet.diagnosis ADD CONSTRAINT diag_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_3dot1_pcornet.demographic (patid);

ALTER TABLE SITE_3dot1_pcornet.diagnosis ADD CONSTRAINT diag_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_3dot1_pcornet.encounter (encounterid);


ALTER TABLE SITE_3dot1_pcornet.procedures ADD CONSTRAINT proc_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_3dot1_pcornet.demographic (patid);

ALTER TABLE SITE_3dot1_pcornet.procedures ADD CONSTRAINT proc_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_3dot1_pcornet.encounter (encounterid);

ALTER TABLE SITE_3dot1_pcornet.dispensing ADD CONSTRAINT disp_fk FOREIGN KEY ( patid ) REFERENCES SITE_3dot1_pcornet.demographic (patid);

ALTER TABLE SITE_3dot1_pcornet.prescribing ADD CONSTRAINT pres_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_3dot1_pcornet.demographic (patid);

ALTER TABLE SITE_3dot1_pcornet.prescribing ADD CONSTRAINT pres_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_3dot1_pcornet.encounter (encounterid);

ALTER TABLE SITE_3dot1_pcornet.vital ADD CONSTRAINT vital_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_3dot1_pcornet.demographic (patid);

ALTER TABLE SITE_3dot1_pcornet.vital ADD CONSTRAINT vital_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_3dot1_pcornet.encounter (encounterid);


ALTER TABLE SITE_3dot1_pcornet.lab_result_cm ADD CONSTRAINT lab_fk_1 FOREIGN KEY ( patid ) REFERENCES SITE_3dot1_pcornet.demographic (patid);

ALTER TABLE SITE_3dot1_pcornet.lab_result_cm ADD CONSTRAINT lab_fk_2 FOREIGN KEY ( encounterid ) REFERENCES SITE_3dot1_pcornet.encounter (encounterid);
commit;