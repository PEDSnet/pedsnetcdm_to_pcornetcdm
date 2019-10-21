begin;

alter table SITE_pcornet.lab_result_cm  alter result_num SET DATA TYPE NUMERIC(25,8);
alter table SITE_pcornet.lab_result_cm  alter result_unit SET DATA TYPE character varying(15);
commit;
begin;
create table SITE_pcornet.lab_measurements as
(
  select measurement_id, person_id, visit_occurrence_id, measurement_concept_id, measurement_source_Concept_id, measurement_source_value, measurement_order_date, measurement_order_datetime,  measurement_datetime, measurement_date, measurement_Result_date, measurement_result_datetime,value_as_number, range_low, range_high, unit_source_value, unit_concept_id, value_as_concept_id,measurement_type_concept_id, priority_source_value, range_high_source_value, range_low_source_value, operator_concept_id,range_low_operator_concept_id, range_high_operator_concept_id, measurement_age_in_months,  value_source_value, measurement_result_age_in_months, measurement_concept_name, measurement_source_concept_name,  measurement_type_concept_name,priority_concept_name, range_high_operator_concept_name, range_low_operator_concept_name, specimen_concept_name,unit_concept_name, value_as_concept_name, site, site_id, provider_id, operator_concept_name, priority_concept_id, specimen_source_value, specimen_concept_id, c1.concept_code as lab_loinc_vocab,c1.concept_name as loinc_desc, case when range_high is not null and range_low is not null then 'EQ|EQ' when range_low is not null and range_high is null then 'GT|NO' when range_high is not null and range_low is null then 'NO|LT' when range_high is null and range_low is null then '|' else 'OT|OT' end as modifier
from SITE_pedsnet.measurement m
inner join vocabulary.concept c1 on m.measurement_concept_id = c1.concept_id and c1.vocabulary_id = 'LOINC'	                  
where measurement_type_Concept_id = 44818702 and measurement_concept_id>0 
 );
commit;
begin;
CREATE INDEX idx_labms_visitid
    ON SITE_pcornet.lab_measurements USING btree
    (visit_occurrence_id)
    TABLESPACE pg_default;
commit;
begin;
CREATE INDEX idx_labms_obsconid
    ON SITE_pcornet.lab_measurements USING btree
    (operator_concept_id)
    TABLESPACE pg_default;
commit;
begin;
CREATE INDEX idx_labms_raglwid
    ON SITE_pcornet.lab_measurements USING btree
    (range_low_operator_concept_id)
    TABLESPACE pg_default;
commit;
begin;
CREATE INDEX idx_labms_raghiid
    ON SITE_pcornet.lab_measurements USING btree
    (range_high_operator_concept_id)
    TABLESPACE pg_default;
commit;
begin;
CREATE INDEX idx_labms_valconid
    ON SITE_pcornet.lab_measurements USING btree
    (value_as_concept_id)
    TABLESPACE pg_default;
commit;
begin;
create table SITE_pcornet.specimen_values as
select distinct on (measurement_id) measurement_id, person_id,visit_occurrence_id,measurement_concept_id, measurement_date, modifier, measurement_datetime, measurement_order_date, measurement_order_datetime, measurement_result_date, measurement_result_datetime, measurement_source_concept_id, measurement_source_value, measurement_type_concept_id, operator_concept_id, priority_concept_id, priority_source_value, range_high, range_high_operator_concept_id, range_high_source_value, range_low, range_low_operator_concept_id, range_low_source_value, specimen_concept_id, specimen_source_value, unit_concept_id, unit_source_value, m.value_as_concept_id, value_as_number, value_source_value, measurement_age_in_months, measurement_result_age_in_months, measurement_concept_name, measurement_source_concept_name, measurement_type_concept_name, operator_concept_name, priority_concept_name, range_high_operator_concept_name, range_low_operator_concept_name, specimen_concept_name, unit_concept_name, value_as_concept_name, site, site_id, provider_id, loinc_desc as raw_lab_name,lab_loinc_vocab as lab_loinc, coalesce(c.target_concept, p.target_concept, 'OT') as specimen_source
from SITE_pcornet.lab_measurements m
left join pcornet_maps.pedsnet_pcornet_valueset_map c on c.source_concept_id = m.specimen_concept_id::text and c.source_concept_class = 'Specimen concept'
left join pcornet_maps.pedsnet_pcornet_valueset_map p on trim(lower(split_part(m.specimen_source_value,'|',1))) = p.source_concept_id and p.source_concept_class = 'Specimen source';
commit;

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
select distinct on (m.measurement_id) m.measurement_id as lab_result_cm_id,
	cast(m.person_id as text) as patid,
	cast(m.visit_occurrence_id as text) as encounterid,
	specimen_source,
	'OD' as lab_result_source,
	'LM' as lab_loinc_source,
	lab_loinc,
	m7.target_concept as priority,
	case when m.measurement_source_value like 'POC%'
	     then 'P'
	     else 'L'
	     end as result_loc,
	null as lab_px,
	null as lab_px_type,
	m.measurement_order_date as lab_order_date,
	m.measurement_date as specimen_date,
	date_part('hour',m.measurement_datetime)||':'||date_part('minute',m.measurement_datetime) as specimen_time,
	coalesce(m.measurement_result_date, m.measurement_date) as result_date,
	date_part('hour',m.measurement_result_datetime)||':'||date_part('minute',m.measurement_result_datetime) as result_time,
	coalesce(m8.target_concept,'OT') as result_qual,
	null as result_snomed, 
	m.value_as_number as result_num,
	m3.target_concept as result_modifier,
	m4.target_concept as result_unit,
	left(m.range_low::text,10) as norm_range_low,
        trim(split_part(m.modifier, '|', 1)) as norm_modifier_low,
	left(m.range_high::text,10) as norm_range_high,
        trim(split_part(m.modifier, '|', 2))  as norm_modifier_high,
	null as abn_ind, -- null for now until new conventions evolve
	raw_lab_name,
	m.measurement_id as raw_lab_code,
	null as raw_panel,
	c2.concept_name || m.value_as_number::text as raw_result,
	m.unit_source_value as raw_unit,
	null as raw_order_dept,
	null as raw_facility_code,
	'SITE' as site
from
	SITE_pcornet.specimen_values m
	left join vocabulary.concept c2 on m.operator_concept_id = c2.concept_id and  c2.domain_id = 'Meas Value Operator'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m3 on cast(m.operator_concept_id as text) = m3.source_concept_id and m3.source_concept_class = 'Result modifier'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m4 on cast(m.unit_concept_id as text)= m4.source_concept_id and m4.source_concept_class = 'Result unit'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m7 on cast(m.priority_concept_id as text)= m7.source_concept_id and m7.source_concept_class = 'Lab priority'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m8 on cast(m.value_as_concept_id as text)= m8.source_concept_id and m8.source_concept_class = 'Result qualifier'
    	where m.visit_occurrence_id IN (select visit_id from SITE_pcornet.person_visit_start2001)
	and EXTRACT(YEAR FROM m.measurement_date)>=2001;

commit;
