begin;


INSERT INTO SITE_pcornet.version_history (operation, model, model_version, dms_version, dmsa_version) VALUES ('create constraints', 'pcornet', '3.1.0', '1.0.4-beta', '0.6.0');

ALTER TABLE SITE_pcornet.condition ADD CONSTRAINT fk_condition_encounterid FOREIGN KEY(encounterid) REFERENCES SITE_pcornet.encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.condition ADD CONSTRAINT fk_condition_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.death ADD CONSTRAINT fk_death_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.death_cause ADD CONSTRAINT fk_death_cause_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.diagnosis ADD CONSTRAINT fk_diagnosis_encounterid FOREIGN KEY(encounterid) REFERENCES SITE_pcornet.encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.diagnosis ADD CONSTRAINT fk_diagnosis_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.dispensing ADD CONSTRAINT fk_dispensing_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.dispensing ADD CONSTRAINT fk_dispensing_prescribingid FOREIGN KEY(prescribingid) REFERENCES SITE_pcornet.prescribing (prescribingid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.encounter ADD CONSTRAINT fk_encounter_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.enrollment ADD CONSTRAINT fk_enrollment_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.lab_result_cm ADD CONSTRAINT fk_lab_result_cm_encounterid FOREIGN KEY(encounterid) REFERENCES SITE_pcornet.encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.lab_result_cm ADD CONSTRAINT fk_lab_result_cm_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.pcornet_trial ADD CONSTRAINT fk_pcornet_trial_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.prescribing ADD CONSTRAINT fk_prescribing_encounterid FOREIGN KEY(encounterid) REFERENCES SITE_pcornet.encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.prescribing ADD CONSTRAINT fk_prescribing_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.pro_cm ADD CONSTRAINT fk_pro_cm_encounterid FOREIGN KEY(encounterid) REFERENCES SITE_pcornet.encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.pro_cm ADD CONSTRAINT fk_pro_cm_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.procedures ADD CONSTRAINT fk_procedures_encounterid FOREIGN KEY(encounterid) REFERENCES SITE_pcornet.encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.procedures ADD CONSTRAINT fk_procedures_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.vital ADD CONSTRAINT fk_vital_encounterid FOREIGN KEY(encounterid) REFERENCES SITE_pcornet.encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE SITE_pcornet.vital ADD CONSTRAINT fk_vital_patid FOREIGN KEY(patid) REFERENCES SITE_pcornet.demographic (patid) DEFERRABLE INITIALLY DEFERRED;


commit;

