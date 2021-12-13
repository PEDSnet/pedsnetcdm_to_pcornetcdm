begin;
create table SITE_pcornet.filter_adt as
select * 
from SITE_pedsnet.adt_occurrence adt
where adt.service_concept_id in (2000000079,2000000080,2000000078);

commit;

begin;
CREATE INDEX idx_filtadt_encid
    ON SITE_pcornet.filter_adt USING btree
    (visit_occurrence_id )
    TABLESPACE pg_default;

commit;

begin;
create table SITE_pcornet.adt_obs
as
select ('a'||adt.adt_occurrence_id)::text as obsgenid,
adt.person_id::text as patid,
adt.visit_occurrence_id::text as encounterid,
enc.providerid as obsgen_providerid,
adt.adt_date::date as obsgen_start_date,
LPAD(date_part('hour',adt.adt_datetime)::text,2,'0')||':'||LPAD(date_part('minute',adt.adt_datetime)::text,2,'0') as obsgen_start_time,
'PC_COVID' as obsgen_type,
'2000' as obsgen_code,
null as obsgen_result_qual,
null as obsgen_abn_ind,
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
enc.discharge_time as obsgen_stop_time,
enc.discharge_date as obsgen_stop_date,
adt.site
from SITE_pcornet.filter_adt adt 
inner join SITE_pcornet.encounter enc on enc.encounterid::int = adt.visit_occurrence_id and enc.admit_date = adt.adt_date;

commit;

begin;
create table SITE_pcornet.meas_obs_filt
as
select ('m'||meas.measurement_id)::text as obsgenid,
meas.person_id::text as patid,
meas.visit_occurrence_id::text as encounterid,
meas.provider_id::text as obsgen_providerid,
meas.measurement_date::date as obsgen_start_date,
LPAD(date_part('hour',measurement_datetime)::text,2,'0')||':'||LPAD(date_part('minute',measurement_datetime)::text,2,'0') as obsgen_start_time,
'PC_COVID' as obsgen_type,
'1000' as obsgen_code,
meas.value_source_value, meas.value_as_concept_id,
case when meas.measurement_concept_id in (2000001422) then 'Y' else 'N' end as obsgen_result_text, -- ,4353936
meas.value_as_number as obsgen_result_num,
meas.operator_concept_id,
meas.unit_concept_id, meas.unit_source_value,
null as obsgen_table_modified,
null as obsgen_id_modified,
'HC' as obsgen_source,
null as raw_obsgen_name,
null as raw_obsgen_type,
null as raw_obsgen_code,
meas.value_as_number as raw_obsgen_result,
meas.unit_concept_name as raw_obsgen_unit,
meas.site,
null as obsgen_stop_time,
null as obsgen_stop_date
from SITE_pedsnet.measurement meas 
where meas.measurement_concept_id in (2000001422,4353936);

commit;

begin;
create table SITE_pcornet.meas_obs_qual
as
select obsgenid,patid,encounterid,obsgen_providerid, obsgen_start_date,obsgen_start_time,
obsgen_type,obsgen_code,
coalesce(map_qual.target_concept, 'OT') as obsgen_result_qual, value_source_value,
obsgen_result_text, obsgen_result_num,meas.operator_concept_id, meas.unit_concept_id, meas.unit_source_value,
obsgen_table_modified,obsgen_id_modified,obsgen_source,raw_obsgen_name,raw_obsgen_type,raw_obsgen_code,
raw_obsgen_result,raw_obsgen_unit,meas.site, obsgen_stop_time, obsgen_stop_date, meas.value_as_concept_id
from SITE_pcornet.meas_obs_filt meas 
left join pcornet_maps.pedsnet_pcornet_valueset_map map_qual on cast(meas.value_as_concept_id as text)= map_qual.source_concept_id and map_qual.source_concept_class = 'Result qualifier';

commit;

begin;
drop table SITE_pcornet.meas_obs_filt;
commit;

begin;
with filter_obsgen as
(
	select obsgenid, obsgen_result_qual, value_source_value
	from SITE_pcornet.meas_obs_qual
	where obsgen_result_qual = 'OT'
	and value_source_value ~ '[a-z]'
)
update SITE_pcornet.meas_obs_qual
set obsgen_result_qual = coalesce(qual.target_concept)
from filter_obsgen l
inner join pcornet_maps.pedsnet_pcornet_valueset_map qual on lower(value_source_value) ilike '%'|| qual.concept_description || '%' and qual.source_concept_class = 'result_qual_source'
where l.obsgenid = SITE_pcornet.meas_obs_qual.obsgenid
and SITE_pcornet.meas_obs_qual.obsgen_result_qual = 'OT';
commit;

begin;
create table SITE_pcornet.meas_obs
as
select distinct obsgenid,patid,encounterid,obsgen_providerid, obsgen_start_date,obsgen_start_time,
obsgen_type,obsgen_code,obsgen_result_qual,
obsgen_result_text, obsgen_result_num,
map_mod.target_concept as obsgen_result_modifier,
coalesce(map.target_concept,'{ratio}') as obsgen_result_unit,coalesce(abn.target_concept, 'NI') as obsgen_abn_ind,
obsgen_table_modified,obsgen_id_modified,obsgen_source,raw_obsgen_name,raw_obsgen_type,raw_obsgen_code,
raw_obsgen_result,raw_obsgen_unit,meas.site, obsgen_stop_time, obsgen_stop_date
from SITE_pcornet.meas_obs_qual meas 
Left join pcornet_maps.pedsnet_pcornet_valueset_map abn on abn.source_concept_id::int = meas.value_as_concept_id and abn.source_concept_class = 'abnormal_indicator'
left join pcornet_maps.pedsnet_pcornet_valueset_map map on map.source_concept_id = meas.unit_concept_id::text and map.source_concept_class = 'Result unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_mod on map.source_concept_id = meas.operator_concept_id::text and map_mod.source_concept_class = 'Result modifier';

commit;

begin;
drop table SITE_pcornet.meas_obs_qual;
commit;

begin;
create table SITE_pcornet.device_obs_filt
as
select ('d'||device_exposure_id)::text as obsgenid,
dev.person_id::text as patid,
dev.visit_occurrence_id::text as encounterid,
dev.provider_id::text as obsgen_providerid,
dev.device_exposure_start_date::date as obsgen_start_date,
LPAD(date_part('hour',dev.device_exposure_start_datetime)::text,2,'0')||':'||LPAD(date_part('minute',dev.device_exposure_start_datetime)::text,2,'0') as obsgen_start_time,
'PC_COVID' as obsgen_type,
'3000' as obsgen_code,
null as obsgen_result_qual,
dev.device_exposure_start_date,dev.device_exposure_end_date,
null as obsgen_result_num,
null as obsgen_result_modifier,
null as obsgen_abn_ind,
null as obsgen_result_unit,
null as obsgen_table_modified,
null as obsgen_id_modified,
'DR' as obsgen_source,
dev.device_concept_id,
null as raw_obsgen_result,
null as raw_obsgen_unit,
dev.device_exposure_end_date::date as obsgen_stop_date,
LPAD(date_part('hour',dev.device_exposure_end_datetime)::text,2,'0')||':'||LPAD(date_part('minute',dev.device_exposure_end_datetime)::text,2,'0') as obsgen_stop_time,
dev.site
from SITE_pedsnet.device_exposure dev
where device_concept_id in (4044008,4097216,4138614,45761494,4224038,4139525,45768222,4222966,40493026);

commit;

begin;
CREATE INDEX idx_devobsfilt_encid
    ON SITE_pcornet.device_obs_filt USING btree
    (encounterid COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

commit;

begin;
create table SITE_pcornet.device_obs
as
select distinct obsgenid,dev.patid,dev.encounterid,dev.obsgen_providerid,dev.obsgen_start_date,obsgen_start_time,
obsgen_type,obsgen_code,obsgen_result_qual,obsgen_abn_ind,
case when dev.device_exposure_start_date <= enc.admit_date and dev.device_exposure_end_date > enc.admit_date
     then 'Y' else 'N' end as obsgen_result_text,
obsgen_result_num,obsgen_result_modifier,obsgen_result_unit,obsgen_table_modified,
obsgen_id_modified,obsgen_source,
snomed.concept_name as raw_obsgen_name,
snomed.vocabulary_id as raw_obsgen_type,
snomed.concept_code as raw_obsgen_code,
raw_obsgen_result,raw_obsgen_unit,dev.site, obsgen_stop_time, obsgen_stop_date
from SITE_pcornet.device_obs_filt dev
inner join SITE_pcornet.encounter enc on enc.encounterid = dev.encounterid
left join vocabulary.concept snomed on snomed.concept_id = dev.device_concept_id and snomed.vocabulary_id in ('SNOMED') and snomed.domain_id = 'Device';

commit;

begin;
create table SITE_pcornet.census_block_group
as
with person_location_id_dates as (
/*
Get person and location id combinations with the first date associated a location id for a given person
where location history is available
*/
    select 
    entity_id as person_id,
    location_id,
    site,
    min(start_date) first_start_date
    from SITE_pedsnet.location_history
    where domain_id='person'
    group by entity_id,location_id,site
),
/*
Capture persons with location information in the person table that does not have an entry in location_history
to associate with a date
*/
person_current_location_no_dates as (
    select distinct
    person_id,
    location_id,
    site,
    null::date as first_start_date
    from SITE_pedsnet.person p
    where not exists (
                    select null 
                    from 
                    person_location_id_dates plid
                    where plid.person_id=p.person_id
                    and plid.location_id=p.location_id)
)
select
('L' ||row_number() over(order by person_locations.person_id,person_locations.location_id))::text as obsgenid,
person_locations.person_id::text as patid,
null as encounterid,
null as obsgen_abn_ind,
'49084-7' as obsgen_code,
loc.location_id::text as obsgen_id_modified,
null as obsgen_providerid,
null as obsgen_result_modifier,
null as obsgen_result_num,
null as obsgen_result_qual,
loc.census_block_group as obsgen_result_text,
null as obsgen_result_unit,
null as obsgen_source,
coalesce(first_start_date,current_date)::date as obsgen_start_date,
null as obsgen_start_time,
null::date as obsgen_stop_date,
null as obsgen_stop_time,
'LDS' as obsgen_table_modified,
'LC' as obsgen_type,
null as raw_obsgen_code,
'Census Block Group (2019)' as raw_obsgen_name,
loc.location_id||'-'||loc.census_block_group as raw_obsgen_result,
null as raw_obsgen_type,
null as raw_obsgen_unit,
person_locations.site
from
    (
    select person_id,
    location_id,
    site,
    first_start_date
    from person_location_id_dates
union
    select person_id,
    location_id,
    site,
    first_start_date
    from person_current_location_no_dates
) person_locations 
inner join SITE_pedsnet.location loc on person_locations.location_id=loc.location_id
where loc.census_block_group is not null
and person_locations.person_id in (select person_id from SITE_pcornet.person_visit_start2001);
commit;



begin;
drop table SITE_pcornet.device_obs_filt;
commit ;

begin;
INSERT INTO SITE_pcornet.obs_gen(obsgenid,encounterid, obsgen_abn_ind, obsgen_code, obsgen_id_modified, obsgen_providerid, obsgen_result_modifier, obsgen_result_num, obsgen_result_qual, obsgen_result_text, obsgen_result_unit, obsgen_source, obsgen_start_date, obsgen_start_time, obsgen_stop_date, obsgen_stop_time, obsgen_table_modified, obsgen_type,  patid, raw_obsgen_code, raw_obsgen_name, raw_obsgen_result, raw_obsgen_type, raw_obsgen_unit, site)
select distinct on (obsgenid) obsgenid, encounterid, obsgen_abn_ind, obsgen_code, obsgen_id_modified, obsgen_providerid, obsgen_result_modifier, obsgen_result_num::numeric, obsgen_result_qual, obsgen_result_text, obsgen_result_unit, obsgen_source, obsgen_start_date, obsgen_start_time, obsgen_stop_date, obsgen_stop_time, obsgen_table_modified, obsgen_type, patid, raw_obsgen_code, raw_obsgen_name, raw_obsgen_result::text, raw_obsgen_type, raw_obsgen_unit, site
from SITE_pcornet.adt_obs
union 
select distinct on (obsgenid) obsgenid, encounterid, obsgen_abn_ind, obsgen_code, obsgen_id_modified, obsgen_providerid, obsgen_result_modifier, obsgen_result_num::numeric, obsgen_result_qual, obsgen_result_text, obsgen_result_unit, obsgen_source, obsgen_start_date, obsgen_start_time, obsgen_stop_date::date, obsgen_stop_time, obsgen_table_modified, obsgen_type, patid, raw_obsgen_code, raw_obsgen_name, raw_obsgen_result::text, raw_obsgen_type, raw_obsgen_unit, site 
from SITE_pcornet.meas_obs
union 
select distinct on (obsgenid) obsgenid, encounterid, obsgen_abn_ind, obsgen_code, obsgen_id_modified, obsgen_providerid, obsgen_result_modifier, obsgen_result_num::numeric, obsgen_result_qual, obsgen_result_text, obsgen_result_unit, obsgen_source, obsgen_start_date, obsgen_start_time, obsgen_stop_date, obsgen_stop_time, obsgen_table_modified, obsgen_type, patid, raw_obsgen_code, raw_obsgen_name, raw_obsgen_result::text, raw_obsgen_type, raw_obsgen_unit, site 
from SITE_pcornet.device_obs
union
select distinct on (obsgenid) obsgenid, encounterid, obsgen_abn_ind, obsgen_code, obsgen_id_modified, obsgen_providerid, obsgen_result_modifier, obsgen_result_num::numeric, obsgen_result_qual, obsgen_result_text, obsgen_result_unit, obsgen_source, obsgen_start_date, obsgen_start_time, obsgen_stop_date, obsgen_stop_time, obsgen_table_modified, obsgen_type, patid, raw_obsgen_code, raw_obsgen_name, raw_obsgen_result::text, raw_obsgen_type, raw_obsgen_unit, site 
from SITE_pcornet.census_block_group;
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
drop table SITE_pcornet.census_block_group;
commit;
