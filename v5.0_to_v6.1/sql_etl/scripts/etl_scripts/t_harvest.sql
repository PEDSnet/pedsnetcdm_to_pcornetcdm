UPDATE SITE_pcornet.harvest
SET 
datamart_name=v1.target_concept,
datamartid=v2.target_concept,
refresh_condition_date  = now()::date,
refresh_death_cause_date = now()::date,
refresh_demographic_date = now()::date,
refresh_diagnosis_date = now()::date,
refresh_dispensing_date = now()::date,
refresh_death_date = now()::date,
refresh_encounter_date = now()::date,
refresh_enrollment_date = now()::date,
refresh_hash_token_date = now()::date,
refresh_immunization_date = now()::date,
refresh_lab_result_cm_date = now()::date,
refresh_lds_address_hx_date = now()::date,
refresh_med_admin_date = now()::date,
refresh_obs_clin_date = now()::date,
refresh_obs_gen_date = now()::date,
refresh_pcornet_trial_date = now()::date,
refresh_prescribing_date = now()::date,
refresh_pro_cm_date = now()::date,
refresh_procedures_date = now()::date,
refresh_provider_date = now()::date,
refresh_vital_date = now()::date,
from pcornet_maps.pedsnet_pcornet_valueset_map v1, pcornet_maps.pedsnet_pcornet_valueset_map v2
WHERE v1.source_concept_id = 'SITE' and
v1.source_concept_class = 'datamart_name' and
v2.source_concept_id = 'SITE' and
v2.source_concept_class = 'datamart_id';