begin;
create sequence obs_gen_seq_id start 1;
commit;

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
create table SITE_pcornet.adt_obs
as
select distinct on (obs.observation_id)obs.observation_id::text as obsgenid,
obs.person_id::text as patid,
obs.visit_occurrence_id::text as encounterid,
obs.provider_id as obsgen_providerid,
obs.observation_date::date as obsgen_date,
LPAD(date_part('hour',observation_datetime)::text,2,'0')||':'||LPAD(date_part('minute',observation_datetime)::text,2,'0') as obsgen_time,
'PC_COVID' as obsgen_type,
'2000' as obsgen_code,
null as obsgen_result_qual,
case when adt.service_concept_id in (2000000079,2000000080,2000000078) then 'Y' else 'N' end as obsgen_result_text,
null as obsgen_result_num,
null as obsgen_result_modifier,
null as obsgen_result_unit,
null as obsgen_table_modified,
null as obsgen_id_modified,
'DR' as obsgen_source,
null as raw_obsgen_name,
null as raw_obsgen_type,
null as raw_obsgen_code,
null as raw_obsgen_result,
null as raw_obsgen_unit,
obs.site
from SITE_pedsnet.adt_occurrence adt  
inner join SITE_pcornet.filter_obs obs on adt.person_id = obs.person_id::int and adt.adt_date = obs.observation_date
where adt.service_concept_id in (2000000079,2000000080,2000000078);

commit;

begin;
create table SITE_pcornet.meas_obs
as
select distinct on (obs.observation_id)obs.observation_id::text as obsgenid,
obs.person_id::text as patid,
obs.visit_occurrence_id::text as encounterid,
obs.provider_id as obsgen_providerid,
obs.observation_date::date as obsgen_date,
LPAD(date_part('hour',observation_datetime)::text,2,'0')||':'||LPAD(date_part('minute',observation_datetime)::text,2,'0') as obsgen_time,
'PC_COVID' as obsgen_type,
'1000' as obsgen_code,
map_qual.target_concept as obsgen_result_qual,
obs.value_as_string as obsgen_result_text,
meas.value_as_number as obsgen_result_num,
map_mod.target_concept as obsgen_result_modifier,
map.target_concept as obsgen_result_unit,
null as obsgen_table_modified,
null as obsgen_id_modified,
'OD' as obsgen_source,
null as raw_obsgen_name,
null as raw_obsgen_type,
null as raw_obsgen_code,
meas.value_as_number as raw_obsgen_result,
meas.unit_concept_name as raw_obsgen_unit,
obs.site
from SITE_pedsnet.measurement meas 
inner join SITE_pcornet.filter_obs obs on meas.person_id = obs.person_id and meas.measurement_date = obs.observation_date 
left join pcornet_maps.pedsnet_pcornet_valueset_map map on map.source_concept_id = meas.unit_concept_id::text and map.source_concept_class = 'Result unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_mod on map.source_concept_id = meas.operator_concept_id::text and map_mod.source_concept_class = 'Result modifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_qual on cast(meas.value_as_concept_id as text)= map_qual.source_concept_id and map_qual.source_concept_class = 'Result qualifier'
where meas.measurement_concept_id in (2000001422,4353936);

commit;

begin;
create table SITE_pcornet.device_obs
as
select distinct on (obs.observation_id)obs.observation_id::text as obsgenid,
obs.person_id::text as patid,
obs.visit_occurrence_id::text as encounterid,
obs.provider_id as obsgen_providerid,
obs.observation_date::date as obsgen_date,
LPAD(date_part('hour',observation_datetime)::text,2,'0')||':'||LPAD(date_part('minute',observation_datetime)::text,2,'0') as obsgen_time,
'PC_COVID' as obsgen_type,
'3000' as obsgen_code,
null as obsgen_result_qual,
case when dev.device_exposure_start_date <= enc.admit_date and dev.device_exposure_end_date > enc.admit_date
     then 'Y' else 'N' end as obsgen_result_text,
null as obsgen_result_num,
null as obsgen_result_modifier,
null as obsgen_result_unit,
null as obsgen_table_modified,
null as obsgen_id_modified,
'DR' as obsgen_source,
null as raw_obsgen_name,
null as raw_obsgen_type,
null as raw_obsgen_code,
null as raw_obsgen_result,
null as raw_obsgen_unit,
obs.site
from SITE_pedsnet.device_exposure dev
left join SITE_pcornet.encounter enc on enc.encounterid::int = dev.visit_occurrence_id
inner join SITE_pcornet.filter_obs obs on obs.person_id = dev.person_id and obs.observation_date = dev.device_exposure_start_date
where device_concept_id in (4044008,4097216,4138614,45761494,4224038,4139525,45768222,4222966,40493026);

commit;

begin;
INSERT INTO SITE_pcornet.obs_gen(
	obsgenid, patid, encounterid, obsgen_providerid,  obsgen_date,obsgen_time, obsgen_type, obsgen_code, obsgen_result_qual, 
	 obsgen_result_text, obsgen_result_num,obsgen_result_modifier,  obsgen_result_unit, obsgen_table_modified, 
	obsgen_id_modified, obsgen_source,raw_obsgen_name,raw_obsgen_type, raw_obsgen_code,  raw_obsgen_result, 
	raw_obsgen_unit, site)
select (nextval('obs_gen_seq_id')) as obsgenid, patid, encounterid, obsgen_providerid,  obsgen_date,obsgen_time, obsgen_type, obsgen_code, obsgen_result_qual, 
	 obsgen_result_text, obsgen_result_num::numeric,obsgen_result_modifier,  obsgen_result_unit, obsgen_table_modified, 
	obsgen_id_modified, obsgen_source,raw_obsgen_name,raw_obsgen_type, raw_obsgen_code,  raw_obsgen_result, 
	raw_obsgen_unit,site 
from SITE_pcornet.adt_obs
union 
select (nextval('obs_gen_seq_id')) as obsgenid, patid, encounterid, obsgen_providerid,  obsgen_date,obsgen_time, obsgen_type, obsgen_code, obsgen_result_qual, 
	 obsgen_result_text, obsgen_result_num,obsgen_result_modifier,  obsgen_result_unit, obsgen_table_modified, 
	obsgen_id_modified, obsgen_source,raw_obsgen_name,raw_obsgen_type, raw_obsgen_code,  raw_obsgen_result::text, 
	raw_obsgen_unit,  site 
from SITE_pcornet.meas_obs
union 
select (nextval('obs_gen_seq_id')) as obsgenid, patid, encounterid, obsgen_providerid,  obsgen_date,obsgen_time, obsgen_type, obsgen_code, obsgen_result_qual, 
	 obsgen_result_text, obsgen_result_num::numeric, obsgen_result_modifier,  obsgen_result_unit, obsgen_table_modified, 
	obsgen_id_modified, obsgen_source,raw_obsgen_name,raw_obsgen_type, raw_obsgen_code,  raw_obsgen_result::text, 
	raw_obsgen_unit,  site 
from SITE_pcornet.device_obs;

commit;

begin;
drop table SITE_pcornet.adt_obs;
drop table SITE_pcornet.meas_obs;
drop table SITE_pcornet.device.obs;
commit;