begin;

alter table SITE_4dot0_pcornet.lab_result_cm  alter result_num SET DATA TYPE NUMERIC(25,8);
alter table SITE_4dot0_pcornet.lab_result_cm  alter result_unit SET DATA TYPE character varying(15);


create table 
SITE_4dot0_pcornet.lab_measurements as
                   (
                      select measurement_id, person_id, visit_occurrence_id, measurement_concept_id,
                             measurement_source_Concept_id, measurement_source_value, measurement_order_date,
                             measurement_datetime, measurement_date, measurement_Result_date, measurement_result_datetime,
	                         value_as_number, range_low, range_high, unit_source_value, unit_concept_id, value_as_concept_id,
	                         operator_concept_id,range_low_operator_concept_id, range_high_operator_concept_id,
	                         priority_concept_id, specimen_source_value,site
	                  from SITE_pedsnet.measurement
	                  where measurement_type_Concept_id = 44818702
	               ); 
	               
insert into SITE_4dot0_pcornet.lab_result_cm (
	lab_result_cm_id,
	patid, encounterid,
	 specimen_source,
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

select
	m.measurement_id as lab_result_cm_id,
	cast(m.person_id as text) as patid,
	cast(m.visit_occurrence_id as text) as encounterid,
	spec_map.target_concept as specimen_source,
	c1.concept_code as lab_loinc,
	m7.target_concept as priority,
	case when measurement_source_value like 'POC%'
	     then 'P'
	     else 'L'
	     end as result_loc,
	null as lab_px,
	null as lab_px_type,
	m.measurement_order_date as lab_order_date,
	m.measurement_date as specimen_date,
	date_part('hour',m.measurement_datetime)||':'||date_part('minute',m.measurement_datetime) as specimen_time,
	coalesce(measurement_result_date, measurement_date) as result_date,
	date_part('hour',m.measurement_result_datetime)||':'||date_part('minute',m.measurement_result_datetime) as result_time,
	coalesce(m8.target_concept,'OT') as result_qual,
	null as result_snomed, 
	m.value_as_number as result_num,
	m3.target_concept as result_modifier,
	m4.target_concept as result_unit,
	left(m.range_low::text,10) as norm_range_low,
	case when m5.target_concept in ('LT','LE')
	     then 'OT'
	     else coalesce(m5.target_concept,'EQ')
	end as norm_modifier_low,
	left(m.range_high::text,10) as norm_range_high,
	case when m6.target_concept in ('GT','GE')
	     then 'OT'
	     else coalesce(m6.target_concept,'EQ')
	end as norm_modifier_high,
	null as abn_ind, -- null for now until new conventions evolve
	c1.concept_name as raw_lab_name,
	m.measurement_id as raw_lab_code,
	null as raw_panel,
	c2.concept_name || m.value_as_number::text as raw_result,
	unit_source_value as raw_unit,
	null as raw_order_dept,
	null as raw_facility_code,
	m.site as site

from
	SITE_4dot0_pcornet.lab_measurements m
	left join vocabulary.concept c1 on m.measurement_concept_id = c1.concept_id and
	                                   c1.vocabulary_id = 'LOINC'
	left join vocabulary.concept c2 on m.operator_concept_id = c2.concept_id and
	                                   c2.domain_id = 'Meas Value Operator'
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m3 on cast(m.operator_concept_id as text) = m3.source_concept_id and
	                                                               m3.source_concept_class = 'Result modifier'
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m4 on cast(m.unit_concept_id as text)= m4.source_concept_id and
	                                                                m4.source_concept_class = 'Result unit'
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m5 on cast(m.range_low_operator_concept_id as text)= m5.source_concept_id and
	                                                                m5.source_concept_class = 'Result modifier'
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m6 on cast(m.range_high_operator_concept_id as text)= m6.source_concept_id and
	                                                                m6.source_concept_class = 'Result modifier'
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m7 on cast(m.priority_concept_id as text)= m7.source_concept_id and
	                                                                m7.source_concept_class = 'Lab priority'
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m8 on cast(m.value_as_concept_id as text)= m8.source_concept_id and
	                                                                m8.source_concept_class = 'Result qualifier'
    left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map spec_map on cast(m.specimen_source_value as text)= spec_map.source_concept_id and
	                                                                spec_map.source_concept_class = 'Specimen source'
	where visit_occurrence_id IN (select visit_id from SITE_4dot0_pcornet.person_visit_start2001)
	and EXTRACT(YEAR FROM measurement_date)>=2001;

commit;
