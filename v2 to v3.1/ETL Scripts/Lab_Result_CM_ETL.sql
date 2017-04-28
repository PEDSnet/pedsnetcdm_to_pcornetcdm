-- more changes likely to be made based on decisions in data models #203 and #204
insert into dcc_3dot1_pcornet.lab_result_cm (
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
	m.measurement_id as lab_result_cm_id,
	m.person_id as patid,
	e.encounterid encounterid,
	m1.target_concept as lab_name,
	--m2.target_concept as specimen_source,
	'BLOOD' as specimen_source, -- defaulting to blood until we have a good solution for sites to figure out how to infer specimen source from labs in the EHR data
	c1.concept_code as lab_loinc,
	m7.target_concept as priority,  -- null for now bring discussed in Data Models #203
	case when measurement_source_value like 'POC%' then 'P' else 'L' end as result_loc, -- using logic to distinguish between POC and L for now - work in progress to explicitly include this in measurement table
	null as lab_px, -- null as discussed in Data Models #204
	null as lab_px_type, -- null as discussed in Data Models #204
	m.measurement_order_date as lab_order_date,
	m.measurement_date as specimen_date,  
	date_part('hour',m.measurement_time)||':'||date_part('minute',m.measurement_time) as specimen_time, -- HH:MI format 
	coalesce(measurement_result_date, measurement_date) as result_date, -- temp fix: use measurement_date is result date is unavailable 
	date_part('hour',m.measurement_result_time)||':'||date_part('minute',m.measurement_result_time) as result_time,
	'NI' as result_qual, -- Assert NI for now --- until new conventions evolve
	m.value_as_number as result_num,
	m3.target_concept as result_modifier,
	m4.target_concept as result_unit,
	left(m.range_low::text,10) as norm_range_low, 
	case when m5.target_concept in ('LT','LE') then 'OT' else m5.target_concept end as norm_modifier_low, 
	left(m.range_high::text,10) as norm_range_high,
	case when m6.target_concept in ('GT','GE') then 'OT' else m6.target_concept end as norm_modifier_high, 
	null as abn_ind, -- null for now until new conventions evolve
	c1.concept_name as raw_lab_name,
	m.measurement_id as raw_lab_code,
	null as raw_panel,
	c2.concept_name || m.value_as_number::text as raw_result,
	unit_source_value as raw_unit,
	null as raw_order_dept,
	null as raw_facility_code,
	site as site 
	
from	 
	dcc_pedsnet.measurement m
	join dcc_3dot1_pcornet.demographic d on cast(m.person_id as text)= d.patid
	join dcc_3dot1_pcornet.encounter e on cast(m.visit_occurrence_id as text) = e.encounterid
	join vocabulary.concept c1 on m.measurement_concept_id = c1.concept_id and c1.vocabulary_id = 'LOINC'
	join vocabulary.concept c2 on m.operator_concept_id = c2.concept_id and c2.domain_id = 'Meas Value Operator'
	join dcc_3dot1_pcornet.cz_omop_pcornet_concept_map m1 on c1.concept_code = m1.source_concept_id and m1.source_concept_class = 'Lab name'
	--left join dcc_3dot1_pcornet.cz_omop_pcornet_concept_map m2 on c1.concept_code = m2.source_concept_id and m2.source_concept_class = 'Specimen source'
	left join dcc_3dot1_pcornet.cz_omop_pcornet_concept_map m3 on cast(m.operator_concept_id as text) = m3.source_concept_id and m3.source_concept_class = 'Result modifier'
	left join dcc_3dot1_pcornet.cz_omop_pcornet_concept_map m4 on cast(m.unit_concept_id as text)= m4.source_concept_id and m4.source_concept_class = 'Unit'
	left join dcc_3dot1_pcornet.cz_omop_pcornet_concept_map m5 on cast(m.range_low_operator_concept_id as text)= m5.source_concept_id and m5.source_concept_class = 'Result modifier'
	left join dcc_3dot1_pcornet.cz_omop_pcornet_concept_map m6 on cast(m.range_high_operator_concept_id as text)= m6.source_concept_id and m6.source_concept_class = 'Result modifier'
	left join dcc_3dot1_pcornet.cz_omop_pcornet_concept_map m7 on cast(m.priority_concept_id as text)= m7.source_concept_id and m7.source_concept_class = 'Lab priority'

