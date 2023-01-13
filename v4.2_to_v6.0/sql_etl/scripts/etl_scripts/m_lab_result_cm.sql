begin;
with filter_lab as
(select measurement_id, specimen_source_value
 from SITE_pcornet.specimen_values
 where specimen_source = 'OT' or specimen_source is null
)
update SITE_pcornet.specimen_values 
set specimen_source = coalesce(s.target_concept, 'OT')
from filter_lab m
inner join pcornet_maps.pedsnet_pcornet_valueset_map s on trim(lower(split_part(m.specimen_source_value,'|',1))) = s.source_concept_id and s.source_concept_class = 'specimen_source'
where m.measurement_id = SITE_pcornet.specimen_values.measurement_id and SITE_pcornet.specimen_values.specimen_source = 'OT' or SITE_pcornet.specimen_values.specimen_source is null;
commit;

begin;
drop table SITE_pcornet.lab_measurements;
commit;

begin;
create table SITE_pcornet.lab_priority_modif
as
select distinct on (m.measurement_id) m.measurement_id as lab_result_cm_id,
	cast(m.person_id as text) as patid,
	cast(m.visit_occurrence_id as text) as encounterid,
	specimen_source,
	'OD' as lab_result_source,
	'LM' as lab_loinc_source,
	lab_loinc,
	priority.target_concept as priority,
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
	LPAD(date_part('hour',m.measurement_result_datetime)::text,2,'0')||':'||LPAD(date_part('minute',m.measurement_result_datetime)::text,2,'0') as result_time,
	m.value_as_concept_id, value_source_value,
	null as result_snomed, 
	m.value_as_number as result_num,
	coalesce(rslt_modif.target_concept, case when trim(split_part(m.modifier, '|', 1)) in ('EQ','GE','GT') then trim(split_part(m.modifier, '|', 1)) when trim(split_part(m.modifier, '|', 2)) in ('EQ','LE','LT') then trim(split_part(m.modifier, '|', 2)) end) as result_modifier,
	m.unit_concept_id,
	left(m.range_low::text,10) as norm_range_low,
    coalesce(case when rslt_modif.target_concept = 'EQ' then 'EQ' when rslt_modif.target_concept in ('GE','GT') then rslt_modif.target_concept when rslt_modif.target_concept in ('LE','LT') then 'NO' end,
			 trim(split_part(m.modifier, '|', 1))) as norm_modifier_low,
	left(m.range_high::text,10) as norm_range_high,
    coalesce(case when rslt_modif.target_concept = 'EQ' then 'EQ' when rslt_modif.target_concept in ('GE','GT') then 'NO' when rslt_modif.target_concept in ('LE','LT') then rslt_modif.target_concept end,
			 trim(split_part(m.modifier, '|', 2)))  as norm_modifier_high,
	null as abn_ind, -- null for now until new conventions evolve
	raw_lab_name,
	raw_lab_code,
	null as raw_panel,
	c2.concept_name || m.value_as_number::text as raw_result,
	m.unit_source_value,
	null as raw_order_dept,
	null as raw_facility_code
from SITE_pcornet.specimen_values m
left join vocabulary.concept c2 on m.operator_concept_id = c2.concept_id and  c2.domain_id = 'Meas Value Operator'
left join pcornet_maps.pedsnet_pcornet_valueset_map rslt_modif on cast(m.operator_concept_id as text) = rslt_modif.source_concept_id and rslt_modif.source_concept_class = 'Result modifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map priority on cast(m.priority_concept_id as text)= priority.source_concept_id and priority.source_concept_class = 'Lab priority';

commit;

begin;
drop table SITE_pcornet.specimen_values;
commit;

begin;
create table SITE_pcornet.lab_unit as
select lab_result_cm_id,patid,encounterid,specimen_source,lab_result_source,lab_loinc_source,
	lab_loinc,priority,result_loc,lab_px,lab_px_type,lab_order_date,specimen_date,specimen_time,
	result_date,result_time,m.value_as_concept_id, value_source_value, result_snomed, result_num,
	result_modifier,
	coalesce(units.target_concept, unit_src.target_concept) as result_unit,
	norm_range_low,
    norm_modifier_low,
	norm_range_high,
    norm_modifier_high,
	abn_ind, -- null for now until new conventions evolve
	raw_lab_name,
	raw_lab_code,
	raw_panel,
	raw_result,
	m.unit_source_value as raw_unit,
	raw_order_dept,
	raw_facility_code
from SITE_pcornet.lab_priority_modif m
left join pcornet_maps.pedsnet_pcornet_valueset_map units on cast(m.unit_concept_id as text)= units.source_concept_id and units.source_concept_class = 'Result unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map unit_src on trim(m.unit_source_value)= unit_src.source_concept_id and unit_src.source_concept_class = 'result_unit_source';

commit;

begin;
drop table SITE_pcornet.lab_priority_modif;
commit;

-- begin;
-- CREATE INDEX idx_labms_valcptid
--     ON SITE_pcornet.lab_unit USING btree
--     (value_as_concept_id)
--     TABLESPACE pg_default;
-- commit;

-- begin;
-- CREATE INDEX idx_labms_valsrcid
--     ON SITE_pcornet.lab_unit USING btree
--     (value_source_value)
--     TABLESPACE pg_default;
-- commit;

begin;
create table SITE_pcornet.lab_qual as
select lab_result_cm_id,patid,encounterid,specimen_source,lab_result_source,lab_loinc_source,lab_loinc,
	priority,result_loc,lab_px,lab_px_type,lab_order_date,specimen_date,specimen_time,result_date,result_time,
	coalesce(qual.target_concept,'OT') as result_qual, value_source_value,
	result_snomed, result_num,result_modifier,result_unit,norm_range_low,norm_modifier_low,norm_range_high,
    norm_modifier_high,abn_ind, raw_lab_name,raw_lab_code,raw_panel,raw_result,raw_unit,raw_order_dept,raw_facility_code
from SITE_pcornet.lab_unit m
left join pcornet_maps.pedsnet_pcornet_valueset_map qual on cast(m.value_as_concept_id as text)= qual.source_concept_id and qual.source_concept_class = 'Result qualifier';
commit;

begin;
with filter_lab as
(
	select lab_result_cm_id, result_qual, value_source_value
	from SITE_pcornet.lab_qual
	where result_qual = 'OT'
	and value_source_value ~ '[a-z]'
)
update SITE_pcornet.lab_qual
set result_qual = coalesce(qual.target_concept)
from filter_lab l
inner join pcornet_maps.pedsnet_pcornet_valueset_map qual on lower(value_source_value) ilike '%'|| qual.concept_description || '%' and qual.source_concept_class = 'result_qual_source'
where l.lab_result_cm_id = SITE_pcornet.lab_qual.lab_result_cm_id
and SITE_pcornet.lab_qual.result_qual = 'OT';
commit;

begin;
drop table SITE_pcornet.lab_unit;
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
	raw_lab_name, raw_lab_code, raw_panel, raw_result, raw_unit, raw_order_dept, raw_facility_code
)
select distinct on (m.lab_result_cm_id) m.lab_result_cm_id as lab_result_cm_id,
	patid,encounterid,specimen_source,lab_result_source,lab_loinc_source,lab_loinc,priority,result_loc,
	lab_px,lab_px_type,lab_order_date,specimen_date, specimen_time,result_date,result_time, result_qual,
	result_snomed, result_num,result_modifier,result_unit,norm_range_low,norm_modifier_low,norm_range_high,
    norm_modifier_high,abn_ind,raw_lab_name,raw_lab_code,raw_panel,raw_result,raw_unit,raw_order_dept,raw_facility_code
from SITE_pcornet.lab_qual m
;

commit;
