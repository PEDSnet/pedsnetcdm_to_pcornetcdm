begin;
Create table SITE_pcornet.filter_obs
as
select * 
from SITE_pedsnet.observation obs
where EXTRACT(YEAR FROM obs.observation_date)>=2001
and obs.person_id in (select person_id from SITE_pcornet.person_visit_start2001)
and (obs.visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001)
	 or obs.visit_occurrence_id is null);
commit;

begin;
create table SITE_pcornet.meas_obsclin_loinc
as
select ('m'||meas.measurement_id)::text as obsclinid,
meas.person_id::text as patid,
meas.visit_occurrence_id::text as encounterid,
meas.provider_id::text as obsclin_providerid,
meas.measurement_date::date as obsclin_start_date,
coalesce(abn.target_concept, 'NI') as obsclin_abn_ind,
LPAD(date_part('hour',measurement_datetime)::text,2,'0')||':'||LPAD(date_part('minute',measurement_datetime)::text,2,'0') as obsclin_start_time,
case when measurement_concept_id = 4353936 then 'SM' else 'LC' end as obsclin_type,
case when meas.measurement_concept_id =4353936 then '250774007' else loinc.concept_code end as obsclin_code,
meas.value_source_value, meas.value_as_concept_id,
case when meas.measurement_concept_id =4353936 then '250774007' else null end as obsclin_result_snomed, 
meas.value_as_number::text as obsclin_result_text,
meas.operator_concept_id,
meas.unit_concept_id, meas.unit_source_value,
'HC' as obsclin_source,
null as raw_obsclin_name,
null as raw_obsclin_type,
null as raw_obsclin_code,
null as raw_obsclin_modifier,
meas.value_as_number::text as raw_obsclin_result,
meas.unit_concept_name as raw_obsclin_unit,
meas.site
from SITE_pedsnet.measurement meas 
left join vocabulary.concept loinc on loinc.concept_id = meas.measurement_concept_id and loinc.vocabulary_id = 'LOINC'
Left join pcornet_maps.pedsnet_pcornet_valueset_map abn on abn.source_concept_id::int = meas.value_as_concept_id and abn.source_concept_class = 'abnormal_indicator'
where meas.measurement_concept_id in (3020891,3024171,40762499,3027018,4353936);

commit;

begin;
create table SITE_pcornet.meas_obsclin_qual
as
select obsclinid,patid,encounterid,obsclin_providerid,obsclin_start_date,obsclin_start_time,obsclin_type,obsclin_code,
coalesce(map_qual.target_concept,qual.target_concept,'OT') as obsclin_result_qual,obsclin_abn_ind, meas.value_source_value,
obsclin_result_snomed, obsclin_result_text,
meas.operator_concept_id,
meas.unit_concept_id, meas.unit_source_value,obsclin_source,raw_obsclin_name,raw_obsclin_type,
raw_obsclin_code,raw_obsclin_modifier,raw_obsclin_result,raw_obsclin_unit,meas.site
from SITE_pcornet.meas_obsclin_loinc meas 
left join pcornet_maps.pedsnet_pcornet_valueset_map map_qual on cast(meas.value_as_concept_id as text)= map_qual.source_concept_id and map_qual.source_concept_class = 'Result qualifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map qual on lower(value_source_value) ilike '%'|| qual.concept_description || '%' and qual.source_concept_class = 'result_qual_source';

commit;

begin;
drop table SITE_pcornet.meas_obsclin_loinc;
commit;


begin;
create table SITE_pcornet.meas_obsclin
as
select obsclinid,patid,encounterid,obsclin_providerid,obsclin_start_date,obsclin_start_time,obsclin_type,obsclin_code,
obsclin_result_qual,obsclin_result_snomed, obsclin_abn_ind, obsclin_result_text,null::date as obsclin_stop_date,null as obsclin_stop_time,
coalesce(map_mod.target_concept,'OT') as obsclin_result_modifier,
map.target_concept as obsclin_result_unit,
obsclin_source,raw_obsclin_name,raw_obsclin_type,
raw_obsclin_code,raw_obsclin_modifier,raw_obsclin_result,raw_obsclin_unit,meas.site
from SITE_pcornet.meas_obsclin_qual meas 
left join pcornet_maps.pedsnet_pcornet_valueset_map map on map.source_concept_id = meas.unit_concept_id::text and map.source_concept_class = 'Result unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_mod on map.source_concept_id = meas.operator_concept_id::text and map_mod.source_concept_class = 'Result modifier';

commit;

begin;
drop table SITE_pcornet.meas_obsclin_qual;
commit;

begin;
delete from SITE_pcornet.meas_obsclin
where patid::int not in (select person_id from SITE_pcornet.person_visit_start2001);

delete from SITE_pcornet.meas_obsclin
where (encounterid is not null
and encounterid::int not in (select visit_id from SITE_pcornet.person_visit_start2001));

commit;

begin;
create table SITE_pcornet.obs_vaping as
select ('o'||obs.observation_id)::text as obsclinid,
obs.person_id::text as patid,
obs.visit_occurrence_id::text as encounterid,
obs.provider_id::text as obsclin_providerid,
coalesce(abn.target_concept, 'NI') as obsclin_abn_ind,
obs.observation_date::date as obsclin_start_date,
LPAD(date_part('hour',obs.observation_datetime)::text,2,'0')||':'||LPAD(date_part('minute',obs.observation_datetime)::text,2,'0') as obsclin_start_time,
'SM' as obsclin_type,
snomed.concept_code as obsclin_code,
coalesce(qual.target_concept,'NI') as obsclin_result_qual,
snomed.concept_code as obsclin_result_snomed, --meas.value_as_number as obsclin_result_snomed,
obs.value_as_string::text as obsclin_result_text,
null as obsclin_result_modifier,
null as obsclin_result_unit,
'HC' as obsclin_source,
null as raw_obsclin_name,
null as raw_obsclin_type,
null as raw_obsclin_code,
null as raw_obsclin_modifier,
null as raw_obsclin_result,
null as raw_obsclin_unit,
null::date as obsclin_stop_date,
null as obsclin_stop_time,
obs.site
from SITE_pcornet.filter_obs obs
left join pcornet_maps.pedsnet_pcornet_valueset_map qual on qual.source_concept_id = obs.qualifier_concept_id::text and qual.source_concept_class in ('Result qualifier')
left join vocabulary.concept snomed on snomed.concept_id = obs.value_as_string::int and snomed.vocabulary_id = 'SNOMED'
Left join pcornet_maps.pedsnet_pcornet_valueset_map abn on abn.source_concept_id::int = obs.value_as_concept_id and abn.source_concept_class = 'abnormal_indicator'
where observation_concept_id = 4219336 and obs.value_as_concept_id in (42536422,42536421,36716478);
commit;

begin;
delete from SITE_pcornet.obs_vaping
where patid::int not in (select person_id from SITE_pcornet.person_visit_start2001);

delete from SITE_pcornet.obs_vaping
where (encounterid is not null
and encounterid::int not in (select visit_id from SITE_pcornet.person_visit_start2001));

commit;
