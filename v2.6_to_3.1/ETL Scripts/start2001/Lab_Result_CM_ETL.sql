
alter table dcc_3dot1_start2001_pcornet.lab_result_cm  alter result_num SET DATA TYPE NUMERIC(20,8);


-- more changes likely to be made based on decisions in data models #203 and #204
insert into dcc_3dot1_start2001_pcornet.lab_result_cm (
	lab_result_cm_id,
	patid, encounterid,
	lab_name, specimen_source,
	lab_loinc, priority, result_loc,
	lab_px, lab_px_type,
	lab_order_date, 
	specimen_date, specimen_time,
	result_date, result_time, result_qual, result_num, result_modifier, result_unit,
	norm_range_low, norm_modifier_low,
	norm_range_high, norm_modifier_high,
	abn_ind,
	raw_lab_name, raw_lab_code, raw_panel, raw_result, raw_unit, raw_order_dept, raw_facility_code, site
)

select 
	lab_result_cm_id,
	patid, encounterid,
	lab_name, specimen_source,
	lab_loinc, priority, result_loc,
	lab_px, lab_px_type,
	lab_order_date, 
	specimen_date, specimen_time,
	result_date, result_time, result_qual, result_num, result_modifier, result_unit,
	norm_range_low, norm_modifier_low,
	norm_range_high, norm_modifier_high,
	abn_ind,
	raw_lab_name, raw_lab_code, raw_panel, raw_result, raw_unit, raw_order_dept, raw_facility_code, site
	 from dcc_3dot1_pcornet.lab_result_cm
where
	encounterid IN (select cast(visit_id as text) from dcc_3dot1_start2001_pcornet.person_visit_start2001)
	and EXTRACT(YEAR FROM specimen_date)>=2001;
