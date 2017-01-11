ALTER TABLE dcc_pcornet.encounter ADD CONSTRAINT enc_fk FOREIGN KEY ( patid ) REFERENCES dcc_pcornet.demographic (patid); 

ALTER TABLE dcc_pcornet.condition ADD CONSTRAINT cond_fk_1 FOREIGN KEY ( patid ) REFERENCES dcc_pcornet.demographic (patid); 

-- following was done
ALTER TABLE dcc_pcornet.condition ADD CONSTRAINT cond_fk_2 FOREIGN KEY ( encounterid ) REFERENCES dcc_pcornet.encounter (encounterid); 

-- following was done
ALTER TABLE dcc_pcornet.diagnosis ADD CONSTRAINT diag_fk_1 FOREIGN KEY ( patid ) REFERENCES dcc_pcornet.demographic (patid); 

ALTER TABLE dcc_pcornet.diagnosis ADD CONSTRAINT diag_fk_2 FOREIGN KEY ( encounterid ) REFERENCES dcc_pcornet.encounter (encounterid); 


ALTER TABLE dcc_pcornet.procedures ADD CONSTRAINT proc_fk_1 FOREIGN KEY ( patid ) REFERENCES dcc_pcornet.demographic (patid); 

ALTER TABLE dcc_pcornet.procedures ADD CONSTRAINT proc_fk_2 FOREIGN KEY ( encounterid ) REFERENCES dcc_pcornet.encounter (encounterid); 

ALTER TABLE dcc_pcornet.dispensing ADD CONSTRAINT disp_fk FOREIGN KEY ( patid ) REFERENCES dcc_pcornet.demographic (patid); 

ALTER TABLE dcc_pcornet.prescribing ADD CONSTRAINT pres_fk_1 FOREIGN KEY ( patid ) REFERENCES dcc_pcornet.demographic (patid); 

ALTER TABLE dcc_pcornet.prescribing ADD CONSTRAINT pres_fk_2 FOREIGN KEY ( encounterid ) REFERENCES dcc_pcornet.encounter (encounterid); 

ALTER TABLE dcc_pcornet.vital ADD CONSTRAINT vital_fk_1 FOREIGN KEY ( patid ) REFERENCES dcc_pcornet.demographic (patid); 

ALTER TABLE dcc_pcornet.vital ADD CONSTRAINT vital_fk_2 FOREIGN KEY ( encounterid ) REFERENCES dcc_pcornet.encounter (encounterid); 


ALTER TABLE dcc_pcornet.lab_result_cm ADD CONSTRAINT lab_fk_1 FOREIGN KEY ( patid ) REFERENCES dcc_pcornet.demographic (patid); 

ALTER TABLE dcc_pcornet.lab_result_cm ADD CONSTRAINT lab_fk_2 FOREIGN KEY ( encounterid ) REFERENCES dcc_pcornet.encounter (encounterid); 
