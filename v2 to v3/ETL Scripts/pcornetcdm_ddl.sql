set search_path to pcornet_cdm;

SHOW search_path;

drop table if exists pcornet_cdm.version_history cascade;

CREATE TABLE pcornet_cdm.version_history (
	datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
	operation VARCHAR(24),
	model VARCHAR(16),
	model_version VARCHAR(16),
	dms_version VARCHAR(16),
	dmsa_version VARCHAR(16),
	PRIMARY KEY (datetime)
);

INSERT INTO pcornet_cdm.version_history (operation, model, model_version, dms_version, dmsa_version) VALUES ('create tables', 'pcornet', '3.0.0', '1.0.1-final.1', '0.5.6');

drop table if exists pcornet_cdm.condition cascade;

CREATE TABLE pcornet_cdm.condition (
	condition VARCHAR(18) NOT NULL,
	condition_source VARCHAR(2) NOT NULL,
	condition_status VARCHAR(2),
	condition_type VARCHAR(2) NOT NULL,
	conditionid VARCHAR(255) NOT NULL,
	encounterid VARCHAR(255),
	onset_date DATE,
	patid VARCHAR(255) NOT NULL,
	raw_condition VARCHAR(255),
	raw_condition_source VARCHAR(255),
	raw_condition_status VARCHAR(255),
	raw_condition_type VARCHAR(255),
	report_date DATE,
	resolve_date DATE,
	CONSTRAINT xpk_condition PRIMARY KEY (conditionid)
);


drop table if exists pcornet_cdm.death cascade;

CREATE TABLE pcornet_cdm.death (
	death_date DATE NOT NULL,
	death_date_impute VARCHAR(2),
	death_match_confidence VARCHAR(2),
	death_source VARCHAR(2) NOT NULL,
	patid VARCHAR(255) NOT NULL,
	CONSTRAINT xpk_death PRIMARY KEY (patid, death_date, death_source)
);


drop table if exists pcornet_cdm.death_cause cascade;

CREATE TABLE pcornet_cdm.death_cause (
	death_cause VARCHAR(8) NOT NULL,
	death_cause_code VARCHAR(2) NOT NULL,
	death_cause_confidence VARCHAR(2),
	death_cause_source VARCHAR(2) NOT NULL,
	death_cause_type VARCHAR(2) NOT NULL,
	patid VARCHAR(255) NOT NULL,
	CONSTRAINT xpk_death_cause PRIMARY KEY (patid, death_cause, death_cause_code, death_cause_type, death_cause_source)
);


drop table if exists pcornet_cdm.demographic cascade;

CREATE TABLE pcornet_cdm.demographic (
	biobank_flag VARCHAR(1),
	birth_date DATE,
	birth_time VARCHAR(5),
	hispanic VARCHAR(2),
	patid VARCHAR(255) NOT NULL,
	race VARCHAR(2),
	raw_hispanic VARCHAR(255),
	raw_race VARCHAR(255),
	raw_sex VARCHAR(255),
	sex VARCHAR(2),
	CONSTRAINT xpk_demographic PRIMARY KEY (patid)
);


drop table if exists pcornet_cdm.diagnosis cascade;

CREATE TABLE pcornet_cdm.diagnosis (
	admit_date DATE,
	diagnosisid VARCHAR(255) NOT NULL,
	dx VARCHAR(18) NOT NULL,
	dx_source VARCHAR(2) NOT NULL,
	dx_type VARCHAR(2) NOT NULL,
	enc_type VARCHAR(2),
	encounterid VARCHAR(255) NOT NULL,
	patid VARCHAR(255) NOT NULL,
	pdx VARCHAR(2),
	providerid VARCHAR(255),
	raw_dx VARCHAR(255),
	raw_dx_source VARCHAR(255),
	raw_dx_type VARCHAR(255),
	raw_pdx VARCHAR(255),
	CONSTRAINT xpk_diagnosis PRIMARY KEY (diagnosisid)
);


drop table if exists pcornet_cdm.dispensing cascade;

CREATE TABLE pcornet_cdm.dispensing (
	dispense_amt NUMERIC(16, 8),
	dispense_date DATE NOT NULL,
	dispense_sup NUMERIC(16, 8),
	dispensingid VARCHAR(255) NOT NULL,
	ndc VARCHAR(11) NOT NULL,
	patid VARCHAR(255) NOT NULL,
	prescribingid VARCHAR(255),
	raw_ndc VARCHAR(255),
	CONSTRAINT xpk_dispensing PRIMARY KEY (dispensingid)
);


drop table if exists pcornet_cdm.encounter cascade;

CREATE TABLE pcornet_cdm.encounter (
	admit_date DATE NOT NULL,
	admit_time VARCHAR(5),
	admitting_source VARCHAR(2),
	discharge_date DATE,
	discharge_disposition VARCHAR(2),
	discharge_status VARCHAR(2),
	discharge_time VARCHAR(5),
	drg VARCHAR(3),
	drg_type VARCHAR(2),
	enc_type VARCHAR(2) NOT NULL,
	encounterid VARCHAR(255) NOT NULL,
	facility_location VARCHAR(3),
	facilityid VARCHAR(255),
	patid VARCHAR(255) NOT NULL,
	providerid VARCHAR(255),
	raw_admitting_source VARCHAR(255),
	raw_discharge_disposition VARCHAR(255),
	raw_discharge_status VARCHAR(255),
	raw_drg_type VARCHAR(255),
	raw_enc_type VARCHAR(255),
	raw_siteid VARCHAR(255),
	CONSTRAINT xpk_encounter PRIMARY KEY (encounterid)
);


drop table if exists pcornet_cdm.enrollment cascade;

CREATE TABLE pcornet_cdm.enrollment (
	chart VARCHAR(1),
	enr_basis VARCHAR(1) NOT NULL,
	enr_end_date DATE,
	enr_start_date DATE NOT NULL,
	patid VARCHAR(255) NOT NULL,
	CONSTRAINT xpk_enrollment PRIMARY KEY (patid, enr_start_date, enr_basis)
);


drop table if exists pcornet_cdm.harvest cascade;

CREATE TABLE pcornet_cdm.harvest (
	admit_date_mgmt VARCHAR(255),
	birth_date_mgmt VARCHAR(255),
	cdm_version NUMERIC(16, 8),
	datamart_claims VARCHAR(2),
	datamart_ehr VARCHAR(2),
	datamart_name VARCHAR(20),
	datamart_platform VARCHAR(2),
	datamartid VARCHAR(10) NOT NULL,
	discharge_date_mgmt VARCHAR(255),
	dispense_date_mgmt VARCHAR(255),
	enr_end_date_mgmt VARCHAR(255),
	enr_start_date_mgmt VARCHAR(255),
	lab_order_date_mgmt VARCHAR(255),
	measure_date_mgmt VARCHAR(255),
	network_name VARCHAR(20),
	networkid VARCHAR(10) NOT NULL,
	onset_date_mgmt VARCHAR(255),
	pro_date_mgmt VARCHAR(255),
	px_date_mgmt VARCHAR(255),
	refresh_condition_date DATE,
	refresh_death_cause_date DATE,
	refresh_death_date DATE,
	refresh_demographic_date DATE,
	refresh_diagnosis_date DATE,
	refresh_dispensing_date DATE,
	refresh_encounter_date DATE,
	refresh_enrollment_date DATE,
	refresh_lab_result_cm_date DATE,
	refresh_pcornet_trial_date DATE,
	refresh_prescribing_date DATE,
	refresh_pro_cm_date DATE,
	refresh_procedures_date DATE,
	refresh_vital_date DATE,
	report_date_mgmt VARCHAR(255),
	resolve_date_mgmt VARCHAR(255),
	result_date_mgmt VARCHAR(255),
	rx_end_date_mgmt VARCHAR(255),
	rx_order_date_mgmt VARCHAR(255),
	rx_start_date_mgmt VARCHAR(255),
	specimen_date_mgmt VARCHAR(255),
	CONSTRAINT xpk_harvest PRIMARY KEY (networkid, datamartid)
);


drop table if exists pcornet_cdm.lab_result_cm cascade;

CREATE TABLE pcornet_cdm.lab_result_cm (
	abn_ind VARCHAR(2),
	encounterid VARCHAR(255),
	lab_loinc VARCHAR(15),
	lab_name VARCHAR(15),
	lab_order_date DATE,
	lab_px VARCHAR(11),
	lab_px_type VARCHAR(2),
	lab_result_cm_id VARCHAR(255) NOT NULL,
	norm_modifier_high VARCHAR(15),
	norm_modifier_low VARCHAR(15),
	norm_range_high VARCHAR(15),
	norm_range_low VARCHAR(15),
	patid VARCHAR(255) NOT NULL,
	priority VARCHAR(2),
	raw_facility_code VARCHAR(255),
	raw_lab_code VARCHAR(255),
	raw_lab_name VARCHAR(255),
	raw_order_dept VARCHAR(255),
	raw_panel VARCHAR(255),
	raw_result VARCHAR(255),
	raw_unit VARCHAR(255),
	result_date DATE NOT NULL,
	result_loc VARCHAR(2),
	result_modifier VARCHAR(2),
	result_num NUMERIC(16, 8),
	result_qual VARCHAR(12),
	result_time VARCHAR(5),
	result_unit VARCHAR(11),
	specimen_date DATE,
	specimen_source VARCHAR(15),
	specimen_time VARCHAR(5),
	CONSTRAINT xpk_lab_result_cm PRIMARY KEY (lab_result_cm_id)
);


drop table if exists pcornet_cdm.pcornet_trial cascade;

CREATE TABLE pcornet_cdm.pcornet_trial (
	participantid VARCHAR(255) NOT NULL,
	patid VARCHAR(255) NOT NULL,
	trial_end_date DATE,
	trial_enroll_date DATE,
	trial_invite_code VARCHAR(20),
	trial_siteid VARCHAR(255),
	trial_withdraw_date DATE,
	trialid VARCHAR(20) NOT NULL,
	CONSTRAINT xpk_pcornet_trial PRIMARY KEY (patid, trialid, participantid)
);


drop table if exists pcornet_cdm.prescribing cascade;

CREATE TABLE pcornet_cdm.prescribing (
	encounterid VARCHAR(255),
	patid VARCHAR(255) NOT NULL,
	prescribingid VARCHAR(255) NOT NULL,
	raw_rx_frequency VARCHAR(255),
	raw_rx_med_name VARCHAR(255),
	raw_rxnorm_cui VARCHAR(255),
	rx_basis VARCHAR(2),
	rx_days_supply NUMERIC(20, 2),
	rx_end_date DATE,
	rx_frequency VARCHAR(2),
	rx_order_date DATE,
	rx_order_time VARCHAR(5),
	rx_providerid VARCHAR(255),
	rx_quantity NUMERIC(20, 2),
	rx_refills NUMERIC(20, 2),
	rx_start_date DATE,
	rxnorm_cui NUMERIC(20, 2),
	CONSTRAINT xpk_prescribing PRIMARY KEY (prescribingid)
);



drop table if exists pcornet_cdm.pro_cm cascade;

CREATE TABLE pcornet_cdm.pro_cm (
	encounterid VARCHAR(255),
	patid VARCHAR(255) NOT NULL,
	pro_cat VARCHAR(2),
	pro_cm_id VARCHAR(255) NOT NULL,
	pro_date DATE NOT NULL,
	pro_item VARCHAR(7) NOT NULL,
	pro_loinc VARCHAR(10),
	pro_method VARCHAR(2),
	pro_mode VARCHAR(2),
	pro_response NUMERIC(16, 8) NOT NULL,
	pro_time VARCHAR(5),
	raw_pro_code VARCHAR(255),
	raw_pro_response VARCHAR(255),
	CONSTRAINT xpk_pro_cm PRIMARY KEY (pro_cm_id)
);


drop table if exists pcornet_cdm.procedures cascade;

CREATE TABLE pcornet_cdm.procedures (
	admit_date DATE,
	enc_type VARCHAR(2),
	encounterid VARCHAR(255) NOT NULL,
	patid VARCHAR(255) NOT NULL,
	proceduresid VARCHAR(255) NOT NULL,
	providerid VARCHAR(255),
	px VARCHAR(11) NOT NULL,
	px_date DATE,
	px_source VARCHAR(255),
	px_type VARCHAR(2) NOT NULL,
	raw_px VARCHAR(255),
	raw_px_type VARCHAR(255),
	CONSTRAINT xpk_procedures PRIMARY KEY (proceduresid)
);


drop table if exists pcornet_cdm.vital cascade;

CREATE TABLE pcornet_cdm.vital (
	bp_position VARCHAR(2),
	diastolic NUMERIC(16, 8),
	encounterid VARCHAR(255),
	ht NUMERIC(16, 8),
	measure_date DATE NOT NULL,
	measure_time VARCHAR(5),
	original_bmi NUMERIC(16, 8),
	patid VARCHAR(255) NOT NULL,
	raw_bp_position VARCHAR(255),
	raw_diastolic VARCHAR(255),
	raw_systolic VARCHAR(255),
	raw_tobacco VARCHAR(255),
	raw_tobacco_type VARCHAR(255),
	smoking VARCHAR(2),
	systolic NUMERIC(16, 8),
	tobacco VARCHAR(2),
	tobacco_type VARCHAR(2),
	vital_source VARCHAR(2) NOT NULL,
	vitalid VARCHAR(255) NOT NULL,
	wt NUMERIC(16, 8),
	CONSTRAINT xpk_vital PRIMARY KEY (vitalid)
);


INSERT INTO pcornet_cdm.version_history (operation, model, model_version, dms_version, dmsa_version) VALUES ('create constraints', 'pcornet', '3.0.0', '1.0.1-final.1', '0.5.6');

ALTER TABLE pcornet_cdm.condition ADD CONSTRAINT fk_condition_encounterid FOREIGN KEY(encounterid) REFERENCES encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.condition ADD CONSTRAINT fk_condition_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.death ADD CONSTRAINT fk_death_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.death_cause ADD CONSTRAINT fk_death_cause_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.diagnosis ADD CONSTRAINT fk_diagnosis_encounterid FOREIGN KEY(encounterid) REFERENCES encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.diagnosis ADD CONSTRAINT fk_diagnosis_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.dispensing ADD CONSTRAINT fk_dispensing_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.dispensing ADD CONSTRAINT fk_dispensing_prescribingid FOREIGN KEY(prescribingid) REFERENCES prescribing (prescribingid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.encounter ADD CONSTRAINT fk_encounter_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.enrollment ADD CONSTRAINT fk_enrollment_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.lab_result_cm ADD CONSTRAINT fk_lab_result_cm_encounterid FOREIGN KEY(encounterid) REFERENCES encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.lab_result_cm ADD CONSTRAINT fk_lab_result_cm_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.pcornet_trial ADD CONSTRAINT fk_pcornet_trial_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.prescribing ADD CONSTRAINT fk_prescribing_encounterid FOREIGN KEY(encounterid) REFERENCES encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.prescribing ADD CONSTRAINT fk_prescribing_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.pro_cm ADD CONSTRAINT fk_pro_cm_encounterid FOREIGN KEY(encounterid) REFERENCES encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.pro_cm ADD CONSTRAINT fk_pro_cm_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.procedures ADD CONSTRAINT fk_procedures_encounterid FOREIGN KEY(encounterid) REFERENCES encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.procedures ADD CONSTRAINT fk_procedures_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.vital ADD CONSTRAINT fk_vital_patid FOREIGN KEY(patid) REFERENCES demographic (patid) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE pcornet_cdm.vital ADD CONSTRAINT fk_vital_encounterid FOREIGN KEY(encounterid) REFERENCES encounter (encounterid) DEFERRABLE INITIALLY DEFERRED;


INSERT INTO pcornet_cdm.version_history (operation, model, model_version, dms_version, dmsa_version) VALUES ('create indexes', 'pcornet', '3.0.0', '1.0.1-final.1', '0.5.6');
