begin;
create table SITE_pcornet.filter_adt as
select * 
from SITE_pedsnet.adt_occurrence adt
where adt.service_concept_id in (2000000079,2000000080,2000000078);

commit;

begin;
create table SITE_pcornet.adt_obs
as
select distinct on (adt.adt_occurrence_id)('a'||adt.adt_occurrence_id)::text as obsgenid,
adt.person_id::text as patid,
adt.visit_occurrence_id::text as encounterid,
enc.providerid as obsgen_providerid,
adt.adt_date::date as obsgen_date,
LPAD(date_part('hour',adt.adt_datetime)::text,2,'0')||':'||LPAD(date_part('minute',adt.adt_datetime)::text,2,'0') as obsgen_time,
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
adt.site
from SITE_pcornet.filter_adt adt 
left join SITE_pcornet.encounter enc on enc.encounterid::int = adt.visit_occurrence_id and enc.admit_date = adt.adt_date
where adt.service_concept_id in (2000000079,2000000080,2000000078);

commit;

begin;
create table SITE_pcornet.meas_obs
as
select distinct on (meas.measurement_id)('m'||meas.measurement_id)::text as obsgenid,
meas.person_id::text as patid,
meas.visit_occurrence_id::text as encounterid,
meas.provider_id::text as obsgen_providerid,
meas.measurement_date::date as obsgen_date,
LPAD(date_part('hour',measurement_datetime)::text,2,'0')||':'||LPAD(date_part('minute',measurement_datetime)::text,2,'0') as obsgen_time,
'PC_COVID' as obsgen_type,
'1000' as obsgen_code,
coalesce(map_qual.target_concept, map_qual_src.target_concept) as obsgen_result_qual,
case when meas.measurement_concept_id in (2000001422,4353936) then 'Y' else 'N' end as obsgen_result_text,
meas.value_as_number as obsgen_result_num,
map_mod.target_concept as obsgen_result_modifier,
coalesce(map.target_concept,'{ratio}') as obsgen_result_unit,
null as obsgen_table_modified,
null as obsgen_id_modified,
'OD' as obsgen_source,
null as raw_obsgen_name,
null as raw_obsgen_type,
null as raw_obsgen_code,
meas.value_as_number as raw_obsgen_result,
meas.unit_concept_name as raw_obsgen_unit,
meas.site
from SITE_pedsnet.measurement meas 
left join pcornet_maps.pedsnet_pcornet_valueset_map map on map.source_concept_id = meas.unit_concept_id::text and map.source_concept_class = 'Result unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_mod on map.source_concept_id = meas.operator_concept_id::text and map_mod.source_concept_class = 'Result modifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_qual on cast(meas.value_as_concept_id as text)= map_qual.source_concept_id and map_qual.source_concept_class = 'Result qualifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_qual_src on cast(meas.value_source_value as text) ilike '%'|| map_qual_src.concept_description || '%' and map_qual_src.source_concept_class = 'result_qual_source'
where meas.measurement_concept_id in (2000001422,4353936);

commit;

begin;
create table SITE_pcornet.device_obs
as
select distinct on (dev.device_exposure_id)('d'||device_exposure_id)::text as obsgenid,
dev.person_id::text as patid,
dev.visit_occurrence_id::text as encounterid,
dev.provider_id::text as obsgen_providerid,
dev.device_exposure_start_date::date as obsgen_date,
LPAD(date_part('hour',dev.device_exposure_start_datetime)::text,2,'0')||':'||LPAD(date_part('minute',dev.device_exposure_start_datetime)::text,2,'0') as obsgen_time,
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
snomed.concept_name as raw_obsgen_name,
snomed.vocabulary_id as raw_obsgen_type,
snomed.concept_code as raw_obsgen_code,
null as raw_obsgen_result,
null as raw_obsgen_unit,
dev.site
from SITE_pedsnet.device_exposure dev
left join SITE_pcornet.encounter enc on enc.encounterid::int = dev.visit_occurrence_id
left join vocabulary.concept snomed on snomed.concept_id = dev.device_concept_id and snomed.vocabulary_id in ('SNOMED') and snomed.domain_id = 'Device'
where device_concept_id in (4044008,4097216,4138614,45761494,4224038,4139525,45768222,4222966,40493026);

commit;

begin;
INSERT INTO SITE_pcornet.obs_gen(
	obsgenid, patid, encounterid, obsgen_providerid,  obsgen_date,obsgen_time, obsgen_type, obsgen_code, obsgen_result_qual, 
	 obsgen_result_text, obsgen_result_num,obsgen_result_modifier,  obsgen_result_unit, obsgen_table_modified, 
	obsgen_id_modified, obsgen_source,raw_obsgen_name,raw_obsgen_type, raw_obsgen_code,  raw_obsgen_result, 
	raw_obsgen_unit, site)
select obsgenid, patid, encounterid, obsgen_providerid,  obsgen_date,obsgen_time, obsgen_type, obsgen_code, obsgen_result_qual, 
	 obsgen_result_text, obsgen_result_num::numeric,obsgen_result_modifier,  obsgen_result_unit, obsgen_table_modified, 
	obsgen_id_modified, obsgen_source,raw_obsgen_name,raw_obsgen_type, raw_obsgen_code,  raw_obsgen_result, 
	raw_obsgen_unit,site 
from SITE_pcornet.adt_obs
union 
select obsgenid, patid, encounterid, obsgen_providerid::text,  obsgen_date,obsgen_time, obsgen_type, obsgen_code, obsgen_result_qual, 
	 obsgen_result_text, obsgen_result_num,obsgen_result_modifier,  obsgen_result_unit, obsgen_table_modified, 
	obsgen_id_modified, obsgen_source,raw_obsgen_name,raw_obsgen_type, raw_obsgen_code,  raw_obsgen_result::text, 
	raw_obsgen_unit,  site 
from SITE_pcornet.meas_obs
union 
select obsgenid, patid, encounterid, obsgen_providerid::text,  obsgen_date,obsgen_time, obsgen_type, obsgen_code, obsgen_result_qual, 
	 obsgen_result_text, obsgen_result_num::numeric, obsgen_result_modifier,  obsgen_result_unit, obsgen_table_modified, 
	obsgen_id_modified, obsgen_source,raw_obsgen_name,raw_obsgen_type, raw_obsgen_code,  raw_obsgen_result::text, 
	raw_obsgen_unit,  site 
from SITE_pcornet.device_obs;

commit;

begin;
delete from SITE_pcornet.obs_gen
where patid::int not in (select person_id from SITE_pcornet.person_visit_start2001);

delete from SITE_pcornet.obs_gen
where (encounterid is not null
and encounterid::int not in (select visit_id from SITE_pcornet.person_visit_start2001));
commit;

begin;
drop table SITE_pcornet.adt_obs;
drop table SITE_pcornet.meas_obs;
drop table SITE_pcornet.device_obs;
commit;