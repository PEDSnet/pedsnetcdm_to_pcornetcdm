begin;

CREATE TABLE IF NOT EXISTS SITE_pcornet.pedsnet_pcornet_valueset_map(
                target_concept character varying(200),
                source_concept_class character varying(200),
                source_concept_id character varying(200),
                value_as_concept_id character varying(200),
                concept_description character varying(200)
                );

CREATE TABLE IF NOT EXISTS SITE_pcornet.version_history(
	datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
	operation VARCHAR(100),
	model VARCHAR(16),
	model_version VARCHAR(50),
	dms_version VARCHAR(50),
	dmsa_version VARCHAR(50),
	PRIMARY KEY (datetime)
);

CREATE TABLE IF NOT EXISTS SITE_pcornet.harvest(
	admit_date_mgmt VARCHAR(2),
	birth_date_mgmt VARCHAR(2),
	cdm_version NUMERIC(15, 8),
	datamart_claims VARCHAR(2),
	datamart_ehr VARCHAR(2),
	datamart_name VARCHAR(20),
	datamart_platform VARCHAR(2),
	datamartid VARCHAR(10) NOT NULL,
	discharge_date_mgmt VARCHAR(2),
	dispense_date_mgmt VARCHAR(2),
	enr_end_date_mgmt VARCHAR(2),
	enr_start_date_mgmt VARCHAR(2),
	lab_order_date_mgmt VARCHAR(2),
	measure_date_mgmt VARCHAR(2),
	network_name VARCHAR(20),
	networkid VARCHAR(10) NOT NULL,
	onset_date_mgmt VARCHAR(2),
	pro_date_mgmt VARCHAR(2),
	px_date_mgmt VARCHAR(2),
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
	report_date_mgmt VARCHAR(2),
	resolve_date_mgmt VARCHAR(2),
	result_date_mgmt VARCHAR(2),
	rx_end_date_mgmt VARCHAR(2),
	rx_order_date_mgmt VARCHAR(2),
	rx_start_date_mgmt VARCHAR(2),
	specimen_date_mgmt VARCHAR(2),
	CONSTRAINT xpk_harvest PRIMARY KEY (networkid, datamartid)
);

CREATE TABLE IF NOT EXISTS SITE_pcornet.pcornet_trial(
	participantid VARCHAR(256) NOT NULL,
	patid VARCHAR(256) NOT NULL,
	trial_end_date DATE,
	trial_enroll_date DATE,
	trial_invite_code VARCHAR(20),
	trial_siteid VARCHAR(256),
	trial_withdraw_date DATE,
	trialid VARCHAR(20) NOT NULL,
	CONSTRAINT xpk_pcornet_trial PRIMARY KEY (patid, trialid, participantid)
);

CREATE TABLE IF NOT EXISTS SITE_pcornet.pro_cm(
	encounterid VARCHAR(256),
	patid VARCHAR(256) NOT NULL,
	pro_cat VARCHAR(2),
	pro_cm_id VARCHAR(256) NOT NULL,
	pro_date DATE NOT NULL,
	pro_item VARCHAR(20) NOT NULL,
	pro_loinc VARCHAR(10),
	pro_method VARCHAR(2),
	pro_mode VARCHAR(2),
	pro_response NUMERIC(15, 8) NOT NULL,
	pro_time VARCHAR(5),
	raw_pro_code VARCHAR(256),
	raw_pro_response VARCHAR(256),
	CONSTRAINT xpk_pro_cm PRIMARY KEY (pro_cm_id)
);

CREATE TABLE IF NOT EXISTS SITE_pcornet.vital(
	bp_position VARCHAR(2),
	diastolic NUMERIC(15, 8),
	encounterid VARCHAR(256),
	ht NUMERIC(15, 8),
	measure_date DATE NOT NULL,
	measure_time VARCHAR(5),
	original_bmi NUMERIC(15, 8),
	patid VARCHAR(256) NOT NULL,
	raw_bp_position VARCHAR(256),
	raw_diastolic VARCHAR(256),
	raw_systolic VARCHAR(256),
	raw_tobacco VARCHAR(256),
	raw_tobacco_type VARCHAR(256),
	smoking VARCHAR(2),
	systolic NUMERIC(15, 8),
	tobacco VARCHAR(2),
	tobacco_type VARCHAR(2),
	vital_source VARCHAR(2) NOT NULL,
	vitalid VARCHAR(256) NOT NULL,
	wt NUMERIC(15, 8),
	CONSTRAINT xpk_vital PRIMARY KEY (vitalid)
);

CREATE TABLE IF NOT EXISTS SITE_pcornet.encounter (
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
	encounterid VARCHAR(256) NOT NULL,
	facility_location VARCHAR(3),
	facilityid VARCHAR(256),
	patid VARCHAR(256) NOT NULL,
	providerid VARCHAR(256),
	raw_admitting_source VARCHAR(256),
	raw_discharge_disposition VARCHAR(256),
	raw_discharge_status VARCHAR(256),
	raw_drg_type VARCHAR(256),
	raw_enc_type VARCHAR(256),
	raw_siteid VARCHAR(256),
	CONSTRAINT xpk_encounter PRIMARY KEY (encounterid)
);

-- INSERT INTO SITE_pcornet.version_history (operation, model, model_version, dms_version, dmsa_version) VALUES ('create constraints', 'pcornet', '3.1.0', '1.0.4-beta', '0.6.0');

commit;
