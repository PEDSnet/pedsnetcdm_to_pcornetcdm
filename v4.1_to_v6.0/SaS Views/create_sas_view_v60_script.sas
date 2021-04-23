/* SAS view definition for PCORnet CDM v6.0 */
libname pcordbms ODBC datasrc = <Data_src_name> SCHEMA=<schema_name>;

/* path where you want the views defined */
libname pcordata '<path>\sas_view_v60';

proc sql;
    /* MED_ADMIN */
    CREATE VIEW pcordata.med_admin AS
        SELECT
        encounterid,
        medadminid,
        medadmin_code,
        medadmin_dose_admin,
        medadmin_dose_admin_unit,
        medadmin_providerid,
        medadmin_route,
        medadmin_source,
        medadmin_start_date,
        input(medadmin_start_time, time5.) format hhmm. as medadmin_start_time,
        medadmin_stop_date,
        input(medadmin_stop_time, time5.) format hhmm. as medadmin_stop_time,
        medadmin_type,        
        patid,
        prescribingid,
        raw_medadmin_code,
        raw_medadmin_dose_admin,
        raw_medadmin_dose_admin_unit,
        raw_medadmin_med_name,
        raw_medadmin_route
    FROM pcordbms.med_admin;

	/* HARVEST */
    CREATE VIEW pcordata.harvest AS 
        SELECT
        address_period_end_mgmt, 
        address_period_start_mgmt,  
        admit_date_mgmt, birth_date_mgmt,  
        cdm_version,  
        datamart_claims,  
        datamart_ehr,  
        datamart_name,  
        datamart_platform,  
        datamartid,  
        death_date_mgmt,  
        discharge_date_mgmt,  
        dispense_date_mgmt,  
        dx_date_mgmt,  
        enr_end_date_mgmt,  
        enr_start_date_mgmt,  
        lab_order_date_mgmt,  
        measure_date_mgmt, 
        medadmin_start_date_mgmt,  
        medadmin_stop_date_mgmt,  
        network_name,  
        networkid,  
		obsclin_start_date_mgmt,  
        obsgen_start_date_mgmt,
        obsclin_stop_date_mgmt,  
        obsgen_stop_date_mgmt,  
        onset_date_mgmt,  
        pro_date_mgmt,  
        px_date_mgmt,  
        refresh_condition_date,  
        refresh_death_cause_date,  
        refresh_death_date,  
        refresh_demographic_date,  
        refresh_diagnosis_date,  
        refresh_dispensing_date,  
        refresh_encounter_date,  
        refresh_enrollment_date,  
        refresh_hash_token_date,  
        refresh_immunization_date,  
        refresh_lab_result_cm_date,  
        refresh_lds_address_hx_date,  
        refresh_med_admin_date,  
        refresh_obs_clin_date,  
        refresh_obs_gen_date,  
        refresh_pcornet_trial_date, 
         refresh_prescribing_date,  
        refresh_pro_cm_date,  
        refresh_procedures_date,  
        refresh_provider_date,  
        refresh_vital_date,  
        report_date_mgmt,  
        resolve_date_mgmt,  
        result_date_mgmt,  
        rx_end_date_mgmt,  
        rx_order_date_mgmt,  
        rx_start_date_mgmt, 
        specimen_date_mgmt,
        token_encryption_key, 
        vx_admin_date_mgmt,  
        vx_exp_date_mgmt,  
        vx_record_date_mgmt
   FROM pcordbms.harvest;
  
  /* DEMOGRAPHICS */
    CREATE VIEW pcordata.demographic AS
        SELECT 
        biobank_flag,
        birth_date,
        input(birth_time, time5.) format hhmm. as birth_time,
        gender_identity,
        hispanic,
        patid,
        pat_pref_language_spoken,
        race,
        raw_gender_identity,
        raw_hispanic,
        raw_pat_pref_language_spoken,
        raw_race,
        raw_sex,
        raw_sexual_orientation,
        sex,
        sexual_orientation
    FROM pcordbms.demographic;

  /* ENCOUNTER */
    CREATE VIEW pcordata.encounter AS
        SELECT 
        admitting_source,
        admit_date,
        input(admit_time, time5.) format hhmm. as admit_time,
        discharge_date,
        discharge_disposition,
        discharge_status,
        input(discharge_time, time5.) format hhmm. as discharge_time,
        drg,
        drg_type,
        encounterid,
        enc_type,
        facilityid,
        facility_location,
        facility_type,
        patid,
        payer_type_primary,
        payer_type_secondary,
        providerid,
        raw_admitting_source,
        raw_discharge_disposition,
        raw_discharge_status,
        raw_drg_type,
        raw_enc_type,
        raw_facility_type,
        raw_payer_id_primary,
        raw_payer_name_primary,
        raw_payer_type_primary,
        raw_payer_id_secondary,
        raw_payer_name_secondary,
        raw_payer_type_secondary,
        raw_siteid
    FROM pcordbms.encounter;

    /* ENROLLMENT */
    CREATE VIEW pcordata.enrollment AS
        SELECT
        chart,
        enr_basis,
        enr_end_date,
        enr_start_date,
        patid
     FROM pcordbms.enrollment;

    /* DIAGNOSIS */
    CREATE VIEW pcordata.diagnosis AS
        SELECT  
        admit_date,
        diagnosisid,
        dx,
        dx_origin,
        dx_poa,
		dx_date,
        dx_source,
        dx_type,
        encounterid,
        enc_type,
        patid,
        pdx,
        providerid,
        raw_dx,
        raw_dx_poa,
        raw_dx_source,
        raw_dx_type,
        raw_pdx
    FROM pcordbms.diagnosis;
    
    /* PROCEDURES */
    CREATE VIEW pcordata.procedures AS
        SELECT 
        admit_date,
        encounterid,
        enc_type,
        patid,
        proceduresid,
        providerid,
        ppx,
        px,
        px_date,
        px_source,
        px_type,
        raw_ppx,
        raw_px,
        raw_px_type
    FROM pcordbms.procedures;

    /* VITALS */
    CREATE VIEW pcordata.vital AS
        SELECT 
        bp_position,
        diastolic,
        encounterid,
        ht,
        measure_date,
        input(measure_time, time5.) format hhmm. as measure_time,
        original_bmi,
        patid,
        raw_bp_position,
        raw_diastolic,
        raw_smoking,
        raw_systolic,
        raw_tobacco,
        raw_tobacco_type,
        smoking,
        systolic,
        tobacco,
        tobacco_type,
        vitalid,
        vital_source,
        wt
    FROM pcordbms.vital;

    /* DISPENSING */
    CREATE VIEW pcordata.dispensing AS
        SELECT
        dispense_amt,
		dispense_source,
        dispense_date,
        dispense_dose_disp,
        dispense_dose_disp_unit,
        dispense_route,
        dispense_sup,
        dispensingid,
        ndc, 
        patid,
        prescribingid,
        raw_ndc,
        raw_dispense_dose_disp,
        raw_dispense_dose_disp_unit,
        raw_dispense_route
    FROM pcordbms.dispensing;

    /* LAB_RESULT_CM */
    CREATE VIEW pcordata.lab_result_cm AS
        SELECT 
        abn_ind, 
        encounterid, 
        lab_loinc, 
        lab_order_date, 
        lab_px, 
		lab_loinc_source,
        lab_px_type, 
        lab_result_cm_id, 
        norm_modifier_high, 
        norm_modifier_low, 
        norm_range_high,  
        norm_range_low,  
        patid,  
        priority,  
        raw_facility_code,  
        raw_lab_code,  
        raw_lab_name,  
        raw_order_dept,  
        raw_panel,  
        raw_result,  
        raw_unit,  
        result_date,  
        result_loc,  
        result_modifier,  
        result_num,  
        result_qual,  
        result_snomed,  
        input(result_time, time5.) format hhmm. as result_time,
        result_unit,  
        specimen_date,  
        specimen_source,  
        input(specimen_time, time5.) format hhmm. as specimen_time,   
        lab_result_source
        from pcordbms.lab_result_cm;

    /* CONDITION */
    CREATE VIEW pcordata.condition AS 
        SELECT 
        condition,
        conditionid,
        condition_source,
        condition_status,
        condition_type,
        encounterid,
        onset_date,
        patid,
        raw_condition,
        raw_condition_source,
        raw_condition_status,
        raw_condition_type,
        report_date,
        resolve_date
    FROM pcordbms.condition;

    /* PRO_CM */
    CREATE VIEW pcordata.pro_cm AS
        SELECT
        encounterid,
        patid, 
        pro_cat, 
        pro_cm_id, 
        pro_date, 
        pro_item_fullname, 
        pro_item_loinc, 
        pro_item_name, 
        pro_item_text, 
        pro_item_version, 
        pro_measure_count_scored, 
        pro_measure_fullname, 
        pro_measure_loinc, 
        pro_measure_name, 
        pro_measure_scaled_tscore, 
        pro_measure_score, 
        pro_measure_seq, 
        pro_measure_standard_error, 
        pro_measure_theta, 
        pro_measure_version, 
        pro_method, 
        pro_mode, 
        pro_response_num, 
        pro_response_text, 
        pro_source, 
        input(pro_time, time5.) format hhmm. AS pro_time, 
        pro_type
    FROM pcordbms.pro_cm;

    /* PRESCRIBING */
    CREATE VIEW pcordata.prescribing AS 
        SELECT
        encounterid,
        patid,
        prescribingid,
        raw_rxnorm_cui,
        raw_rx_dose_ordered,
        raw_rx_dose_ordered_unit,
        raw_rx_frequency,
        raw_rx_med_name,
        raw_rx_ndc,
        raw_rx_quantity,
        raw_rx_refills,
        raw_rx_route,
        rxnorm_cui,
        rx_basis,
        rx_days_supply,
        rx_dispense_as_written,
        rx_dose_form,
        rx_dose_ordered,
        rx_dose_ordered_unit,
        rx_end_date,
        rx_frequency,
        rx_order_date,
        input(rx_order_time, time5.) format hhmm. as rx_order_time,
        rx_prn_flag,
        rx_providerid,
        rx_quantity,
        rx_quantity_unit,
        rx_refills,
        rx_route,
        rx_source,
        rx_start_date
    FROM pcordbms.prescribing;

    /* PCORNET_TRIAL */
    CREATE VIEW pcordata.pcornet_trial AS
        SELECT
        participantid,
        patid,
        trial_end_date,
        trial_enroll_date,
        trial_invite_code, 
        trial_siteid,
        trial_withdraw_date,
        trialid
    FROM pcordbms.pcornet_trial;

    
   /* DEATH */
    CREATE VIEW pcordata.death AS 
        SELECT  
        death_date,
        death_date_impute,
        death_match_confidence,
        death_source,
        patid
    FROM pcordbms.death;


    /* DEATH_CAUSE */
    CREATE VIEW pcordata.death_cause AS
        SELECT
        death_cause,
        death_cause_code,
        death_cause_confidence,
        death_cause_source, 
        death_cause_type,
        patid
    FROM pcordbms.death_cause;

	/* PROVIDER */
    CREATE VIEW pcordata.provider AS
        SELECT
        providerid,
        provider_npi,
        provider_npi_flag,
        provider_sex,
        provider_specialty_primary,
        raw_provider_specialty_primary
    FROM pcordbms.provider;
    
    /* OBS_CLIN */
    CREATE VIEW pcordata.obs_clin AS
        SELECT
        encounterid,
        obsclinid,
        obsclin_code,
		obsclin_source,
        obsclin_start_date,
        obsclin_stop_date,
        obsclin_providerid,
        obsclin_result_modifier,
        obsclin_result_num,
        obsclin_result_qual,
        obsclin_result_snomed,
        obsclin_result_text,
        obsclin_result_unit,
        input(obsclin_start_time, time5.) format hhmm. as obsclin_start_time,
        input(obsclin_stop_time, time5.) format hhmm. as obsclin_stop_time,
        obsclin_type,
        patid,
        raw_obsclin_code,
        raw_obsclin_modifier,
        raw_obsclin_name,
        raw_obsclin_result,
        raw_obsclin_type,
        raw_obsclin_unit
    FROM pcordbms.obs_clin;
        
    /* OBS_GEN */
    CREATE VIEW pcordata.obs_gen AS
        SELECT
        encounterid,
        obsgen_code,
        obsgen_start_date,
        obsgen_stop_date,
        obsgen_id_modified,
        obsgen_providerid,
        obsgen_result_modifier,
        obsgen_result_num,
        obsgen_result_qual,
        obsgen_result_text,
        obsgen_result_unit,
        obsgen_table_modified,
        input(obsgen_start_time, time5.) format hhmm. as obsgen_start_time,
        input(obsgen_stop_time, time5.) format hhmm. as obsgen_stop_time,
        obsgen_type,
        obsgenid,
        patid,
        raw_obsgen_code,
        raw_obsgen_name,
        raw_obsgen_result,
        raw_obsgen_type,
        raw_obsgen_unit,
		obsgen_source
    FROM pcordbms.obs_gen;
	
	
	/* Hash token */
	 CREATE VIEW pcordata.hash_token AS
        SELECT
		patid,
		token_01,
		token_02,
		token_03,
		token_04,
		token_05,
		token_16
	FROM pcordbms.hash_token;

	
	/*  LDS_ADDRESS_HISTORY  */
		CREATE VIEW pcordata.lds_address_history AS
			SELECT
			addressid,
			patid,
			address_use,
			address_type,
			address_preferred,
			address_city,
			address_state,
			address_zip5,
			address_zip9,
			address_period_start,
			address_period_end
		FROM pcordbms.lds_address_history;
			
	
	/*  IMMUNIZATION */
	    CREATE VIEW pcordata.immunization AS
            SELECT
            immunizationid,
			patid,
			encounterid,
			proceduresid,
			vx_providerid,
			vx_record_date,
			vx_admin_date,
			vx_code_type,
			vx_code,
			vx_status,
			vx_status_reason,
			vx_source,
			vx_dose,
			vx_dose_unit,
			vx_route,
			vx_body_site,
			vx_manufacturer,
			vx_lot_num,
			vx_exp_date,
			raw_vx_name,
			raw_vx_code,
			raw_vx_code_type,
			raw_vx_dose,
			raw_vx_dose_unit,
			raw_vx_route,
			raw_vx_body_site,
			raw_vx_status,
			raw_vx_status_reason,
			raw_vx_manufacturer
		FROM pcordbms.immunization;

	/* LAB_HISTORY */
	   CREATE VIEW pcordata.lab_history AS
	        SELECT
			age_max_wks,
			age_min_wks,
			lab_facilityid,
            lab_loinc,
			labhistoryid,
			norm_modifier_high,
			norm_modifier_low,
			norm_range_high,
			norm_range_low,
			period_end,
			period_start,
			race,
            raw_lab_name,
			raw_range,
			result_unit,
			sex
		FROM pcordbms.lab_history;
	
quit;

