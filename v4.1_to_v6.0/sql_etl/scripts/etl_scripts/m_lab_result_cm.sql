begin;

alter table SITE_pcornet.lab_result_cm  alter result_num SET DATA TYPE NUMERIC(25,8);
alter table SITE_pcornet.lab_result_cm  alter result_unit SET DATA TYPE character varying(256);
commit;
begin;
create table SITE_pcornet.lab_measurements as
(
  select measurement_id, person_id, visit_occurrence_id, measurement_concept_id, measurement_source_Concept_id, measurement_source_value, measurement_order_date, measurement_order_datetime,  measurement_datetime, measurement_date, measurement_Result_date, measurement_result_datetime,value_as_number, range_low, range_high, unit_source_value, unit_concept_id, m.value_as_concept_id,measurement_type_concept_id, priority_source_value, range_high_source_value, range_low_source_value, operator_concept_id,range_low_operator_concept_id, range_high_operator_concept_id, value_source_value, measurement_concept_name, measurement_source_concept_name,  measurement_type_concept_name,priority_concept_name, range_high_operator_concept_name, range_low_operator_concept_name, specimen_concept_name,unit_concept_name, value_as_concept_name, site, site_id, provider_id, operator_concept_name, priority_concept_id, specimen_source_value, specimen_concept_id, c1.concept_code as lab_loinc_vocab,c1.concept_name as loinc_desc, raw_loinc.concept_code as raw_lab_loinc_vocab,raw_loinc.concept_name as raw_loinc_desc,
	case when range_high_operator_concept_id = range_low_operator_concept_id  then 'EQ|EQ'
	when range_low_operator_concept_id in (4171754,4172703,4171755) and 
	range_high_operator_concept_id in (4172703,4171755,4171754,4171756) then 'GE|NO'
	when range_low_operator_concept_id in (4171754,4171756) and 
	range_high_operator_concept_id in (4172703,4171755,4171756) then 'GT|NO'
	when range_low_operator_concept_id in (4171755,4172704) and 
	range_high_operator_concept_id in (4172703,4171756) then 'NO|LE'
	when range_low_operator_concept_id in (4172703,4172704,4171754,4171756) and 
	range_high_operator_concept_id in (4172704) then 'NO|LT'
	else hi.target_concept||'|'||lo.target_concept end as modifier
  from SITE_pedsnet.measurement m
  inner join vocabulary.concept c1 on m.measurement_concept_id = c1.concept_id and c1.vocabulary_id = 'LOINC' and concept_class_id='Lab Test'
  left join vocabulary.concept raw_loinc on m.measurement_source_concept_id = raw_loinc.concept_id and raw_loinc.vocabulary_id = 'LOINC' and raw_loinc.concept_class_id='Lab Test'
  left join pcornet_maps.pedsnet_pcornet_valueset_map hi on hi.source_concept_id = m.range_high_operator_concept_id::text and hi.source_concept_class = 'Result modifier'
  left join pcornet_maps.pedsnet_pcornet_valueset_map lo on lo.source_concept_id = m.range_low_operator_concept_id::text and lo.source_concept_class = 'Result modifier'
  where measurement_type_Concept_id = 44818702 and measurement_concept_id>0 
  and m.visit_occurrence_id IN (select visit_id from SITE_pcornet.person_visit_start2001)
  and EXTRACT(YEAR FROM m.measurement_date)>=2001
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
select measurement_id, person_id,visit_occurrence_id,measurement_concept_id, measurement_date, modifier, measurement_datetime, measurement_order_date, measurement_order_datetime, measurement_result_date, measurement_result_datetime, measurement_source_concept_id, measurement_source_value, measurement_type_concept_id, operator_concept_id, priority_concept_id, priority_source_value, range_high, range_high_operator_concept_id, range_high_source_value, range_low, range_low_operator_concept_id, range_low_source_value, specimen_concept_id, specimen_source_value, unit_concept_id, unit_source_value, m.value_as_concept_id, value_as_number, value_source_value, measurement_concept_name, measurement_source_concept_name, measurement_type_concept_name, operator_concept_name, priority_concept_name, range_high_operator_concept_name, range_low_operator_concept_name, specimen_concept_name, unit_concept_name, value_as_concept_name, site, site_id, provider_id, loinc_desc as raw_lab_name,lab_loinc_vocab as lab_loinc, raw_lab_loinc_vocab as raw_lab_code, coalesce(c.target_concept, s.target_concept,spec_src.target_concept,'OT') as specimen_source
from SITE_pcornet.lab_measurements m
left join pcornet_maps.pedsnet_pcornet_valueset_map c on c.source_concept_id = m.specimen_concept_id::text and c.source_concept_class = 'Specimen concept'
left join pcornet_maps.pedsnet_pcornet_valueset_map s on s.source_concept_id = m.lab_loinc_vocab and s.source_concept_class = 'specimen_loinc'
left join pcornet_maps.pedsnet_pcornet_valueset_map spec_src on trim(lower(split_part(m.specimen_source_value,'|',1))) = spec_src.source_concept_id and spec_src.source_concept_class = 'specimen_source';

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
	date_part('hour',m.measurement_result_datetime)||':'||date_part('minute',m.measurement_result_datetime) as result_time,
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
	null as raw_facility_code,
	'SITE' as site
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
	raw_facility_code,
	site
from SITE_pcornet.lab_priority_modif m
left join pcornet_maps.pedsnet_pcornet_valueset_map units on cast(m.unit_concept_id as text)= units.source_concept_id and units.source_concept_class = 'Result unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map unit_src on trim(m.unit_source_value)= unit_src.source_concept_id and unit_src.source_concept_class = 'result_unit_source';

commit;

begin;
drop table SITE_pcornet.lab_priority_modif;
commit;

begin;
CREATE INDEX idx_labms_valcptid
    ON SITE_pcornet.lab_unit USING btree
    (value_as_concept_id)
    TABLESPACE pg_default;
commit;

begin;
CREATE INDEX idx_labms_valsrcid
    ON SITE_pcornet.lab_unit USING btree
    (value_source_value)
    TABLESPACE pg_default;
commit;

begin;
create table SITE_pcornet.lab_qual as
select lab_result_cm_id,patid,encounterid,specimen_source,lab_result_source,lab_loinc_source,lab_loinc,
	priority,result_loc,lab_px,lab_px_type,lab_order_date,specimen_date,specimen_time,result_date,result_time,
	coalesce(qual.target_concept,qual_src.target_concept,'OT') as result_qual, value_source_value,
	result_snomed, result_num,result_modifier,result_unit,norm_range_low,norm_modifier_low,norm_range_high,
    norm_modifier_high,abn_ind, raw_lab_name,raw_lab_code,raw_panel,raw_result,raw_unit,raw_order_dept,raw_facility_code,site
from SITE_pcornet.lab_unit m
left join pcornet_maps.pedsnet_pcornet_valueset_map qual on cast(m.value_as_concept_id as text)= qual.source_concept_id and qual.source_concept_class = 'Result qualifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map qual_src on lower(trim(regexp_replace(value_source_value, '([!$()*+.:<=>?[\\\]^{|}-])', '\\\1', 'g'))) ilike lower(regexp_replace(qual_src.concept_description, '([!$()*+.:<=>?[\\\]^{|}-])', '\\\1', 'g')) ESCAPE '\' and qual_src.source_concept_class = 'result_qual_source' and m.value_as_concept_id = 0 and m.value_source_value ~* '[a-z]';

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
