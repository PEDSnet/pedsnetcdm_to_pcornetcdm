begin;

INSERT INTO SITE_pcornet.obs_gen(
	obsgenid, patid, encounterid, obsgen_providerid,  obsgen_date,obsgen_time, obsgen_type, obsgen_code, obsgen_result_qual, 
	 obsgen_result_text, obsgen_result_num,obsgen_result_modifier,  obsgen_result_unit, obsgen_table_modified, 
	obsgen_id_modified, obsgen_source,raw_obsgen_name,raw_obsgen_type, raw_obsgen_code,  raw_obsgen_result, 
	raw_obsgen_unit,  site)
select distinct on (obs.observation_id)obs.observation_id::text as obsgenid,
obs.person_id::text as patid,
obs.visit_occurrence_id::text as encounterid,
obs.provider_id as obsgen_providerid,
obs.observation_date::date as obsgen_date,
LPAD(date_part('hour',observation_datetime)::text,2,'0')||':'||LPAD(date_part('minute',observation_datetime)::text,2,'0') as obsgen_time,
case when adt.service_concept_id in (2000000079,2000000080,2000000078) then 'PC_COVID' 
      when meas.measurement_concept_id in (2000001422) then 'PC_COVID'
      else null end as obsgen_type,
case when adt.service_concept_id in (2000000079,2000000080,2000000078) then '2000' 
      when meas.measurement_concept_id in (2000001422) then '1000'
      else null end as obsgen_code,
null as obsgen_result_qual,
case when meas.measurement_concept_id in (2000001422) then obs.value_as_string
else null end  as obsgen_result_text,
case when meas.measurement_concept_id in (2000001422) then obs.value_as_number
else null end as obsgen_result_num,
null as obsgen_result_modifier,
case when meas.measurement_concept_id in (2000001422) then map.target_concept
else null end as obsgen_result_unit,
null as obsgen_table_modified,
null as obsgen_id_modified,
case when adt.service_concept_id in (2000000079,2000000080,2000000078) then 'DR'
      when meas.measurement_concept_id in (2000001422) then 'OD'
      else null end  as obsgen_source,
null as raw_obsgen_name,
null as raw_obsgen_type,
null as raw_obsgen_code,
case when meas.measurement_concept_id in (2000001422) then obs.value_as_string
else null end  as raw_obsgen_result,
case when meas.measurement_concept_id in (2000001422) then obs.unit_source_value
else null end as raw_obsgen_unit,
obs.site
from SITE_pedsnet.observation obs
left join SITE_pcornet.encounter enc on enc.encounterid::int = obs.visit_occurrence_id 
left join SITE_pedsnet.adt_occurrence adt on adt.visit_occurrence_id = enc.encounterid::int and adt.service_concept_id in (2000000079,2000000080,2000000078)
left join SITE_pedsnet.measurement meas on meas.person_id = obs.person_id and meas.visit_occurrence_id = obs.visit_occurrence_id and meas.measurement_concept_id in (2000001422)
left join pcornet_maps.pedsnet_pcornet_valueset_map map on map.source_concept_id = obs.unit_concept_id::text and map.source_concept_class = 'Result unit'
where EXTRACT(YEAR FROM obs.observation_date)>=2001
	and obs.person_id in (select person_id from SITE_pcornet.person_visit_start2001);


commit;