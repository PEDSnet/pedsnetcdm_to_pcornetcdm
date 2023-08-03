begin;

insert into SITE_pcornet.lab_result_cm (
	lab_result_cm_id,
	patid, encounterid,
	specimen_source, lab_result_source, lab_loinc_source,
	lab_loinc, priority, result_loc,
	lab_px, lab_px_type,
	lab_order_date,
	specimen_date, specimen_time,
	result_date, result_time, result_qual, result_snomed, 
	result_num, result_modifier, result_unit,
	norm_range_low, norm_modifier_low,
	norm_range_high, norm_modifier_high,
	abn_ind,
	raw_lab_name, raw_lab_code, raw_panel, raw_result, raw_unit, raw_order_dept, raw_facility_code, site
)
select distinct on (m.lab_result_cm_id) m.lab_result_cm_id as lab_result_cm_id,
	patid,encounterid,specimen_source,lab_result_source,lab_loinc_source,lab_loinc,priority,result_loc,
	lab_px,lab_px_type,lab_order_date,specimen_date, specimen_time,result_date,result_time, result_qual,
	result_snomed, result_num,result_modifier,result_unit,norm_range_low,norm_modifier_low,norm_range_high,
    norm_modifier_high,abn_ind,raw_lab_name,raw_lab_code,raw_panel,raw_result,raw_unit,raw_order_dept,raw_facility_code,site
from SITE_pcornet.lab_qual m
where m.encounterid::int IN (select visit_id from SITE_pcornet.person_visit_start2001);

commit;