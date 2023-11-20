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
coalesce(
    map_qual.target_concept, 
    case
            when lower(value_source_value) like '%1+%' then '1+'
            when lower(value_source_value) like '%2+%' then '2+'
            when lower(value_source_value) like '%3+%' then '3+'
            when lower(value_source_value) like '%a neg%' then 'A NEG'
            when lower(value_source_value) like '%a pos%' then 'A POS'
            when lower(value_source_value) like '%ab negative%' then 'AB NEG'
            when lower(value_source_value) like '%ab not detected%' then 'AB NOT DETECTED'
            when lower(value_source_value) like '%ab positive%' then 'AB POS'
            when lower(value_source_value) like '%abbnormal%' then 'ABNORMAL'
            when lower(value_source_value) like '%abnormal%' then 'ABNORMAL'
            when lower(value_source_value) like '%absent%' then 'ABSENT'
            when lower(value_source_value) like '%acanthocytes%' then 'ACANTHOCYTES'
            when lower(value_source_value) like '%adequate%' then 'ADEQUATE'
            when lower(value_source_value) like '%amber%' then 'AMBER'
            when lower(value_source_value) like '%amniotic fluid%' then 'AMNIOTIC FLUID'
            when lower(value_source_value) like '%anisocytosis%' then 'ANISOCYTOSIS'
            when lower(value_source_value) like '%arterial%' then 'ARTERIAL'
            when lower(value_source_value) like '%arterial line%' then 'ARTERIAL LINE'
            when lower(value_source_value) like '%b neg%' then 'B NEG'
            when lower(value_source_value) like '%b pos%' then 'B POS'
            when lower(value_source_value) like '%basophilic stippling%' then 'BASOPHILIC STIPPLING'
            when lower(value_source_value) like '%bite cells%' then 'BITE CELLS'
            when lower(value_source_value) like '%bizarre%' then 'BIZARRE CELLS'
            when lower(value_source_value) like '%black%' then 'BLACK'
            when lower(value_source_value) like '%blister cells%' then 'BLISTER CELLS'
            when lower(value_source_value) like '%blood%' then 'BLOOD'
            when lower(value_source_value) like '%bone marrow%' then 'BONE MARROW'
            when lower(value_source_value) like '%brown%' then 'BROWN'
            when lower(value_source_value) like '%burr cells%' then 'BURR CELLS'
            when lower(value_source_value) like '%cerebrospinal fluid%' then 'CEREBROSPINAL FLUID (CSF)'
            when lower(value_source_value) like '%clean catch%' then 'CLEAN CATCH'
            when lower(value_source_value) like '%Clear%' then 'CLEAR'
            when lower(value_source_value) like '%CLEAR%' then 'CLEAR'
            when lower(value_source_value) like '%clear%' then 'CLEAR'
            when lower(value_source_value) like '%cloudy%' then 'CLOUDY'
            when lower(value_source_value) like '%colorless%' then 'COLORLESS'
            when lower(value_source_value) like '%dacrocytes%' then 'DACROCYTES'
            when lower(value_source_value) like '%detected%' then 'DETECTED'
            when lower(value_source_value) like '%elliptocytes%' then 'ELLIPTOCYTES'
            when lower(value_source_value) like '%equivocal%' then 'EQUIVOCAL'
            when lower(value_source_value) like '%few%' then 'FEW'
            when lower(value_source_value) like '%green%' then 'GREEN'
            when lower(value_source_value) like '%hair%' then 'HAIR'
            when lower(value_source_value) like '%hazy%' then 'HAZY'
            when lower(value_source_value) like '%helmet%' then 'HELMET CELLS'
            when lower(value_source_value) like '%heterozygous%' then 'HETEROZYGOUS'
            when lower(value_source_value) like '%howelljolly%' then 'HOWELL-JOLLY BODIES'
            when lower(value_source_value) like '%howell jolly%' then 'HOWELL-JOLLY BODIES'
            when lower(value_source_value) like '%howell-jolly%' then 'HOWELL-JOLLY BODIES'
            when lower(value_source_value) like '%immune%' then 'IMMUNE'
            when lower(value_source_value) like '%Inconclusive%' then 'INCONCLUSIVE'
            when lower(value_source_value) like '%increased%' then 'INCREASED'
            when lower(value_source_value) like '%indeterminate%' then 'INDETERMINATE'
            when lower(value_source_value) like '%influenza A virus%' then 'INFLUENZA A VIRUS'
            when lower(value_source_value) like '%influenza B virus%' then 'INFLUENZA B VIRUS'
            when lower(value_source_value) like '%invalid%' then 'INVALID'
            when lower(value_source_value) like '%large%' then 'LARGE'
            when lower(value_source_value) like '%left arm%' then 'LEFT ARM'
            when lower(value_source_value) like '%low%' then 'LOW'
            when lower(value_source_value) like '%macrocytes%' then 'MACROCYTES'
            when lower(value_source_value) like '%many%' then 'MANY'
            when lower(value_source_value) like '%microcytes%' then 'MICROCYTES'
            when lower(value_source_value) like '%moderate%' then 'MODERATE'
            when lower(value_source_value) like '%nasopharyngeal%' then 'NASOPHARYNGEAL'
            when lower(value_source_value) like '%neg%' then 'NEGATIVE'
            when lower(value_source_value) like '%tnp%' then 'NI'
            when lower(value_source_value) like '%no growth%' then 'NO GROWTH'
            when lower(value_source_value) like '%none%' then 'NONE'
            when lower(value_source_value) like '%nonreactive%' then 'NONREACTIVE'
            when lower(value_source_value) like '%normal%' then 'NORMAL'
            when lower(value_source_value) like '%none detected.%' then 'NOT DETECTED'
            when lower(value_source_value) like '%not detected%' then 'NOT DETECTED'
            when lower(value_source_value) like '%o negative%' then 'O NEG'
            when lower(value_source_value) like '%o positive%' then 'O POS'
            when lower(value_source_value) like '%occasional%' then 'OCCASIONAL'
            when lower(value_source_value) like '%@%' then 'OT'
            when lower(value_source_value) like '%see Comment%' then 'OT'
            when lower(value_source_value) like '%ovalocytes%' then 'OVALOCYTES'
            when lower(value_source_value) like '%pappenheimer bodies%' then 'PAPPENHEIMER BODIES'
            when lower(value_source_value) like '%peritoneal fluid%' then 'PERITONEAL FLUID'
            when lower(value_source_value) like '%pink%' then 'PINK'
            when lower(value_source_value) like '%plasma%' then 'PLASMA'
            when lower(value_source_value) like '%pos%' then 'POSITIVE'
            when lower(value_source_value) like '%rare%' then 'RARE'
            when lower(value_source_value) like '%reactive%' then 'REACTIVE'
            when lower(value_source_value) like '%right arm%' then 'RIGHT ARM'
            when lower(value_source_value) like '%sars coronavirus 2%' then 'SARS CORONAVIRUS 2'
            when lower(value_source_value) like '%slight%' then 'SLIGHT'
            when lower(value_source_value) like '%Slightly Cloudy%' then 'SLIGHTLY CLOUDY'
            when lower(value_source_value) like '%small%' then 'SMALL'
            when lower(value_source_value) like '%Specimen unsatisfactory for evaluation%' then 'SPECIMEN UNSATISFACTORY FOR EVALUATION'
            when lower(value_source_value) like '%stomatocytes%' then 'STOMATOCYTES'
            when lower(value_source_value) like '%stool%' then 'STOOL'
            when lower(value_source_value) like '%straw%' then 'STRAW'
            when lower(value_source_value) like '%suspect%' then 'SUSPECTED'
            when lower(value_source_value) like '%synovial fluid%' then 'SYNOVIAL FLUID'
            when lower(value_source_value) like '%trace%' then 'TRACE'
            when lower(value_source_value) like '%turbid%' then 'TURBID'
            when lower(value_source_value) like '%unknown%' then 'UN'
            when lower(value_source_value) like '%undetected%' then 'UNDETECTABLE'
            when lower(value_source_value) like '%inconclusive%' then 'UNDETERMINED'
            when lower(value_source_value) like '%urine%' then 'URINE'
            when lower(value_source_value) like '%white%' then 'WHITE'
            when lower(value_source_value) like '%yellow%' then 'YELLOW'
	end,
    'OT') as obsgen_result_qual, 
value_source_value,
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

-- start census block group
begin;
create table SITE_pcornet.census_block_group as

/*
Get person and location id combinations with the first date associated a location id for a given person
where location history is available
*/
with person_location_id_dates as (
    select 
        entity_id as person_id,
        location_id,
        site,
        start_date,
        end_date
    from 
        SITE_pedsnet.location_history
    where 
        trim(lower(domain_id))='person'
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
        null::date as start_date,
        null::date as end_date
    from 
        SITE_pedsnet.person p
    where 
        not exists 
            (
                select null 
                from person_location_id_dates plid
                where plid.person_id=p.person_id
                and plid.location_id=p.location_id
            )
)
select
    ('L' || fips.geocode_id::text || fips.location_id::text || person_locations.person_id::text || (row_number() over(order by person_locations.person_id,person_locations.location_id))::text)::text as obsgenid,
    person_locations.person_id::text as patid,
    null as encounterid,
    null as obsgen_abn_ind,
    '49084-7' as obsgen_code,
    fips.location_id::text as obsgen_id_modified,
    null as obsgen_providerid,
    null as obsgen_result_modifier,
    null as obsgen_result_num,
    null as obsgen_result_qual,
    fips.geocode_state::text || fips.geocode_county::text || fips.geocode_tract::text || fips.geocode_group::text || fips.geocode_block::text as obsgen_result_text,
    null as obsgen_result_unit,
    null as obsgen_source,
    coalesce(start_date,current_date)::date as obsgen_start_date,
    null as obsgen_start_time,
    end_date::date as obsgen_stop_date,
    null as obsgen_stop_time,
    'LDS' as obsgen_table_modified,
    'LC' as obsgen_type,
    null as raw_obsgen_code,
    'Census Block Group' as raw_obsgen_name,
    fips.location_id||' - '|| fips.geocode_state::text || fips.geocode_county::text || fips.geocode_tract::text || fips.geocode_group::text || fips.geocode_block::text as raw_obsgen_result,
    geocode_year::text as raw_obsgen_type,
    geocode_shapefile::text as raw_obsgen_unit,
    person_locations.site
from
    (
    select 
        person_id,
        location_id,
        site,
        start_date,
        end_date
    from 
        person_location_id_dates
    union
    select
         person_id,
        location_id,
        site,
        start_date,
        end_date
    from 
        person_current_location_no_dates
    ) as person_locations 
inner join 
    SITE_pedsnet.location_fips fips 
    on person_locations.location_id=fips.location_id
where
    person_locations.person_id in (select person_id from SITE_pcornet.person_visit_start2001);
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
