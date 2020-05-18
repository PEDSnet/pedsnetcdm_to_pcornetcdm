begin;

create table SITE_pcornet.meas_obsclin
as
select distinct on (obs.observation_id)obs.observation_id::text as obsclinid,
obs.person_id::text as patid,
obs.visit_occurrence_id::text as encounterid,
obs.provider_id as obsclin_providerid,
obs.observation_date::date as obsclin_date,
LPAD(date_part('hour',observation_datetime)::text,2,'0')||':'||LPAD(date_part('minute',observation_datetime)::text,2,'0') as obsclin_time,
'LC' as obsclin_type,
loinc.concept_code as obsclin_code,
coalesce(map_qual.target_concept,map_qual.target_concept) as obsclin_result_qual,
obs.value_as_string as obsclin_result_text,
meas.value_as_number as obsclin_result_num,
map_mod.target_concept as obsclin_result_modifier,
map.target_concept as obsclin_result_unit,
null as obsclin_table_modified,
null as obsclin_id_modified,
'OD' as obsclin_source,
null as raw_obsclin_name,
null as raw_obsclin_type,
null as raw_obsclin_code,
meas.value_as_number as raw_obsclin_result,
meas.unit_concept_name as raw_obsclin_unit,
obs.site
from SITE_pedsnet.measurement meas 
inner join SITE_pcornet.filter_obs obs on meas.person_id = obs.person_id and meas.measurement_date = obs.observation_date 
left join vocabulary.concept loinc on loinc.concept_id = meas.measurement_concept_id and loinc.vocabulary_id = 'LOINC'
left join pcornet_maps.pedsnet_pcornet_valueset_map map on map.source_concept_id = meas.unit_concept_id::text and map.source_concept_class = 'Result unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_mod on map.source_concept_id = meas.operator_concept_id::text and map_mod.source_concept_class = 'Result modifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_qual on cast(meas.value_as_concept_id as text)= map_qual.source_concept_id and map_qual.source_concept_class = 'Result qualifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_qual on cast(m.value_source_value as text) ilike '%'|| map_qual.concept_description || '%' and map_qual.source_concept_class = 'result_qual_source'
where meas.measurement_concept_id in (3020891,3024171,40762499,3027018,4353936);

commit;

begin;
INSERT INTO SITE_pcornet.obs_clin(
	obsclinid, patid, encounterid, obsclin_providerid,  obsclin_date,obsclin_time, obsclin_type, obsclin_code, obsclin_result_qual, 
	 obsclin_result_text, obsclin_result_num,obsclin_result_modifier,  obsclin_result_unit, obsclin_table_modified, 
	obsclin_id_modified, obsclin_source,raw_obsclin_name,raw_obsclin_type, raw_obsclin_code,  raw_obsclin_result, 
	raw_obsclin_unit, site)
select obsclinid, patid, encounterid, obsclin_providerid,  obsclin_date,obsclin_time, obsclin_type, obsclin_code, obsclin_result_qual, 
	 obsclin_result_text, obsclin_result_num,obsclin_result_modifier,  obsclin_result_unit, obsclin_table_modified, 
	obsclin_id_modified, obsclin_source,raw_obsclin_name,raw_obsclin_type, raw_obsclin_code,  raw_obsclin_result::text, 
	raw_obsclin_unit,  site 
from SITE_pcornet.meas_obsclin;

commit;

begin;

drop table SITE_pcornet.meas_obsclin;

commit;