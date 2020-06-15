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
create table SITE_pcornet.meas_obsclin
as
select distinct on (meas.measurement_id)('m'||meas.measurement_id)::text as obsclinid,
meas.person_id::text as patid,
meas.visit_occurrence_id::text as encounterid,
meas.provider_id::text as obsclin_providerid,
meas.measurement_date::date as obsclin_date,
LPAD(date_part('hour',measurement_datetime)::text,2,'0')||':'||LPAD(date_part('minute',measurement_datetime)::text,2,'0') as obsclin_time,
case when measurement_concept_id = 4353936 then 'SM' else 'LC' end as obsclin_type,
case when meas.measurement_concept_id =4353936 then '250774007' else loinc.concept_code end as obsclin_code,
coalesce(map_qual.target_concept,map_qual_src.target_concept) as obsclin_result_qual,
case when meas.measurement_concept_id =4353936 then '250774007' else null end as obsclin_result_snomed, --meas.value_as_number as obsclin_result_snomed,
meas.value_as_number::text as obsclin_result_text,
map_mod.target_concept as obsclin_result_modifier,
map.target_concept as obsclin_result_unit,
'OD' as obsclin_source,
null as raw_obsclin_name,
null as raw_obsclin_type,
null as raw_obsclin_code,
null as raw_obsclin_modifier,
meas.value_as_number::text as raw_obsclin_result,
meas.unit_concept_name as raw_obsclin_unit,
meas.site
from SITE_pedsnet.measurement meas 
-- inner join SITE_pcornet.filter_obs obs on meas.person_id = obs.person_id and meas.measurement_date = obs.observation_date 
left join vocabulary.concept loinc on loinc.concept_id = meas.measurement_concept_id and loinc.vocabulary_id = 'LOINC'
left join pcornet_maps.pedsnet_pcornet_valueset_map map on map.source_concept_id = meas.unit_concept_id::text and map.source_concept_class = 'Result unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_mod on map.source_concept_id = meas.operator_concept_id::text and map_mod.source_concept_class = 'Result modifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_qual on cast(meas.value_as_concept_id as text)= map_qual.source_concept_id and map_qual.source_concept_class = 'Result qualifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_qual_src on cast(meas.value_source_value as text) ilike '%'|| map_qual_src.concept_description || '%' and map_qual_src.source_concept_class = 'result_qual_source'
where meas.measurement_concept_id in (3020891,3024171,40762499,3027018,4353936);

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
select distinct on (obs.observation_id)('o'||obs.observation_id)::text as obsclinid,
obs.person_id::text as patid,
obs.visit_occurrence_id::text as encounterid,
obs.provider_id::text as obsclin_providerid,
obs.observation_date::date as obsclin_date,
LPAD(date_part('hour',obs.observation_datetime)::text,2,'0')||':'||LPAD(date_part('minute',obs.observation_datetime)::text,2,'0') as obsclin_time,
'SM' as obsclin_type,
snomed.concept_code as obsclin_code,
null as obsclin_result_qual,
snomed.concept_code as obsclin_result_snomed, --meas.value_as_number as obsclin_result_snomed,
obs.value_as_string::text as obsclin_result_text,
null as obsclin_result_modifier,
null as obsclin_result_unit,
'OD' as obsclin_source,
null as raw_obsclin_name,
null as raw_obsclin_type,
null as raw_obsclin_code,
null as raw_obsclin_modifier,
null as raw_obsclin_result,
null as raw_obsclin_unit,
obs.site
from SITE_pcornet.filter_obs obs
left join vocabulary.concept snomed on snomed.concept_id = obs.value_as_string::int and snomed.vocabulary_id = 'SNOMED'
where observation_concept_id = 4219336 and value_as_concept_id in (42536422,42536421,36716478);
commit;

begin;
delete from SITE_pcornet.obs_vaping
where patid::int not in (select person_id from SITE_pcornet.person_visit_start2001);

delete from SITE_pcornet.obs_vaping
where (encounterid is not null
and encounterid::int not in (select visit_id from SITE_pcornet.person_visit_start2001));

commit;

begin;
INSERT INTO SITE_pcornet.obs_clin(encounterid, obsclin_code, obsclin_date, obsclin_providerid, obsclin_result_modifier, obsclin_result_snomed, obsclin_result_qual, obsclin_result_text, 
	obsclin_result_unit, obsclin_source, obsclin_time, obsclin_type, obsclinid, patid, raw_obsclin_code, raw_obsclin_modifier, raw_obsclin_name, raw_obsclin_result, raw_obsclin_type, 
	raw_obsclin_unit, site)
select encounterid, obsclin_code, obsclin_date, obsclin_providerid::text, obsclin_result_modifier, obsclin_result_snomed, obsclin_result_qual, obsclin_result_text::text, 
	obsclin_result_unit, obsclin_source, obsclin_time, obsclin_type, obsclinid, patid, raw_obsclin_code, raw_obsclin_modifier, raw_obsclin_name, raw_obsclin_result::text, raw_obsclin_type, 
	raw_obsclin_unit, site 
from SITE_pcornet.meas_obsclin
union
select encounterid, obsclin_code, obsclin_date, obsclin_providerid::text, obsclin_result_modifier, obsclin_result_snomed, obsclin_result_qual, obsclin_result_text, 
	obsclin_result_unit, obsclin_source, obsclin_time, obsclin_type, obsclinid, patid, raw_obsclin_code, raw_obsclin_modifier, raw_obsclin_name, raw_obsclin_result, raw_obsclin_type, 
	raw_obsclin_unit, site 
from SITE_pcornet.obs_vaping;

commit;

begin;
delete from SITE_pcornet.obs_clin
where patid::int not in (select person_id from SITE_pcornet.person_visit_start2001);

delete from SITE_pcornet.obs_clin
where (encounterid is not null
and encounterid::int not in (select visit_id from SITE_pcornet.person_visit_start2001));

commit;

begin;
update SITE_pcornet.obs_clin
set obsclin_result_modifier = 'UN'
where obsclin_result_modifier = 'NO';
commit;

begin;

--drop table SITE_pcornet.meas_obsclin;
--drop table SITE_pcornet.obs_vaping;

commit;