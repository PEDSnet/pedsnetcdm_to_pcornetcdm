begin;
ALTER TABLE SITE_pcornet.vital ALTER original_bmi SET DATA TYPE NUMERIC(20,8);
commit;
begin;
create sequence IF NOT EXISTS sq_vitalid start 1;
commit;

-- extract all fields 
begin;
create table SITE_pcornet.ms_ht as
(
    select  distinct person_id, 'SITE' as site, measurement_id,visit_occurrence_id, measurement_date, measurement_datetime, value_as_number
	,  measurement_concept_id,measurement_source_value, provider_id,operator_concept_id, unit_concept_id, unit_source_value, value_as_concept_id,
	value_source_value,measurement_type_concept_id
	from SITE_pedsnet.measurement
	where measurement_concept_id = '3023540'
);
commit;

begin;
CREATE INDEX idx_msht_mdtm
    ON SITE_pcornet.ms_ht USING btree
    (measurement_datetime)
    TABLESPACE pg_default;

CREATE INDEX idx_msht_visid
   ON SITE_pcornet.ms_ht USING btree
   (visit_occurrence_id)
   TABLESPACE pg_default;
commit;
begin;
create table SITE_pcornet.ms_wt as
(
   select person_id, 'SITE' as site, measurement_id,visit_occurrence_id, measurement_date, measurement_datetime, value_as_number
	,  measurement_concept_id,measurement_source_value, provider_id,operator_concept_id, unit_concept_id, unit_source_value, value_as_concept_id,
	value_source_value,measurement_type_concept_id
	from SITE_pedsnet.measurement
	where measurement_concept_id = '3013762'
);
commit;
begin;
CREATE INDEX idx_mswt_mdtm
    ON SITE_pcornet.ms_wt USING btree
    (measurement_datetime)
    TABLESPACE pg_default;

CREATE INDEX idx_mswt_visid
    ON SITE_pcornet.ms_wt USING btree
    (visit_occurrence_id)
    TABLESPACE pg_default;

commit;
begin;
create table SITE_pcornet.ms_bmi as
(
    select distinct person_id, 'SITE' as site, measurement_id,visit_occurrence_id, provider_id, value_as_concept_id,
	measurement_date, measurement_datetime, value_as_number,  measurement_concept_id,measurement_source_value,operator_concept_id, unit_concept_id, unit_source_value,
	value_source_value,measurement_type_concept_id
    from SITE_pedsnet.measurement
    where measurement_concept_id = '3038553'
);
commit;
begin;
    CREATE INDEX idx_msbm_msdtm
        ON SITE_pcornet.ms_bmi USING btree
        (measurement_datetime)
        TABLESPACE pg_default;

    CREATE INDEX idx_msbm_visid
        ON SITE_pcornet.ms_bmi USING btree
        (visit_occurrence_id)
        TABLESPACE pg_default;
commit;
begin;
create table SITE_pcornet.ms_sys as
(
   select distinct person_id, 'SITE' as site, measurement_id, visit_occurrence_id, provider_id, value_as_concept_id,
		measurement_date, measurement_datetime, value_as_number,  measurement_concept_id,measurement_source_value,operator_concept_id, unit_concept_id, unit_source_value,
	value_source_value,measurement_type_concept_id
   from SITE_pedsnet.measurement
   where measurement_concept_id in ('3018586','3035856','3009395','3004249')
);
commit;
begin;
CREATE INDEX idx_mssy_mdtm
    ON SITE_pcornet.ms_sys USING btree
    (measurement_datetime)
    TABLESPACE pg_default;

CREATE INDEX idx_mssy_visid
    ON SITE_pcornet.ms_sys USING btree
    (visit_occurrence_id)
    TABLESPACE pg_default;
commit;
begin;
create table SITE_pcornet.ms_dia as
(
    select distinct person_id, 'SITE' as site, measurement_id, provider_id, value_as_concept_id,
		visit_occurrence_id, measurement_date, measurement_datetime, value_as_number, 
			 measurement_concept_id,measurement_source_value,operator_concept_id, unit_concept_id, unit_source_value,
	value_source_value,measurement_type_concept_id
	from SITE_pedsnet.measurement
	where measurement_concept_id in ('3034703','3019962','3013940','3012888')
);
commit;
begin;
    CREATE INDEX idx_msdi_msdtm
        ON SITE_pcornet.ms_dia USING btree
        (measurement_datetime)
        TABLESPACE pg_default;

    CREATE INDEX idx_msdi_visid
        ON SITE_pcornet.ms_dia USING btree
        (visit_occurrence_id)
        TABLESPACE pg_default;
commit;

begin;
create table SITE_pcornet.ms as
	select person_id, site, measurement_id, visit_occurrence_id, value_as_concept_id, measurement_date, measurement_datetime, value_as_number, measurement_concept_id, measurement_source_value, provider_id,operator_concept_id, unit_concept_id, unit_source_value,
	value_source_value,measurement_type_concept_id
	from SITE_pcornet.ms_ht
	UNION
	select person_id, site, measurement_id, visit_occurrence_id, value_as_concept_id, measurement_date, measurement_datetime, value_as_number, measurement_concept_id, measurement_source_value, provider_id,operator_concept_id, unit_concept_id, unit_source_value,
	value_source_value,measurement_type_concept_id
	from SITE_pcornet.ms_wt
	UNION
	select person_id, site, measurement_id, visit_occurrence_id, value_as_concept_id, measurement_date, measurement_datetime, value_as_number, measurement_concept_id, measurement_source_value, provider_id,operator_concept_id, unit_concept_id, unit_source_value,
	value_source_value,measurement_type_concept_id
	from SITE_pcornet.ms_bmi
	UNION
	select person_id, site, measurement_id, visit_occurrence_id, value_as_concept_id, measurement_date, measurement_datetime, value_as_number, measurement_concept_id, measurement_source_value, provider_id,operator_concept_id, unit_concept_id, unit_source_value,
	value_source_value,measurement_type_concept_id
	from SITE_pcornet.ms_sys
	UNION
	select person_id, site, measurement_id, visit_occurrence_id, value_as_concept_id, measurement_date, measurement_datetime, value_as_number, measurement_concept_id, measurement_source_value, provider_id,operator_concept_id, unit_concept_id, unit_source_value,
	value_source_value,measurement_type_concept_id
	from SITE_pcornet.ms_dia;
commit;

begin;
delete from SITE_pcornet.ms
where EXTRACT(YEAR FROM measurement_date) >= 2001 and
      ms.person_id not in (select person_id from SITE_pcornet.person_visit_start2001) and
      ms.visit_occurrence_id not in (select visit_id from SITE_pcornet.person_visit_start2001);

commit;

begin;
    CREATE INDEX idx_ms_dtm
        ON SITE_pcornet.ms USING btree
        (measurement_datetime)
        TABLESPACE pg_default;

    CREATE INDEX ms_vis
        ON SITE_pcornet.ms USING btree
        (visit_occurrence_id)
        TABLESPACE pg_default;

commit;		

begin;
create table SITE_pcornet.ob_tobacco as
(
    select distinct observation_id, observation_concept_id,observation_source_value,person_id, o1.value_as_concept_id, visit_occurrence_id, qualifier_source_value, observation_date, observation_datetime, provider_id,
    value_as_string, coalesce(m1.target_concept,'OT') as tobacco, f.fact_id_2, qualifier_concept_id,o1.site
	from SITE_pedsnet.observation o1
	left join pcornet_maps.pedsnet_pcornet_valueset_map m1 on cast(o1.value_as_concept_id as text) = m1.value_as_concept_id
	left join SITE_pedsnet.fact_relationship f on o1.observation_id = f.fact_id_1
	where observation_concept_id IN ('4005823') and m1.source_concept_class = 'tobacco'
);
commit;
begin;
CREATE INDEX idx_tbc_factid
    ON SITE_pcornet.ob_tobacco USING btree
    (fact_id_2)
    TABLESPACE pg_default;
commit;
begin;
create table SITE_pcornet.ob_tobacco_type as
(
    select distinct visit_occurrence_id, observation_concept_id, observation_source_value,o1.value_as_concept_id, observation_date, observation_datetime, coalesce(m2.target_concept,'OT') as tobacco_type, qualifier_source_value,observation_id, qualifier_concept_id,o1.site,provider_id
	from SITE_pedsnet.observation o1 
	left join pcornet_maps.pedsnet_pcornet_valueset_map m2 on o1.value_as_concept_id::text = m2.value_as_concept_id
	where observation_concept_id IN ('4219336') and m2.source_concept_class = 'tobacco type'
	and EXTRACT(YEAR FROM observation_date) >= 2001 and
      person_id in (select person_id from SITE_pcornet.person_visit_start2001) and
      visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001)
);
commit;
begin;
CREATE INDEX idx_toty_obsid
    ON SITE_pcornet.ob_tobacco_type USING btree
    (observation_id)
    TABLESPACE pg_default;
commit;
begin;
create table SITE_pcornet.ob_smoking as
(
    select distinct observation_id, observation_source_value, visit_occurrence_id, o1.value_as_concept_id, observation_date, observation_datetime, coalesce(m3.target_concept,'OT') as smoking, observation_concept_id, qualifier_concept_id,o1.site,qualifier_source_value,provider_id
	from SITE_pedsnet.observation o1 left join pcornet_maps.pedsnet_pcornet_valueset_map m3 on o1.value_as_concept_id::text = m3.value_as_concept_id
	where observation_concept_id IN ('4275495') and m3.source_concept_class = 'smoking'
	and EXTRACT(YEAR FROM observation_date) >= 2001 and
      person_id in (select person_id from SITE_pcornet.person_visit_start2001) and
      visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001)
);
commit;
begin;
CREATE INDEX idx_tosmk_obsid
    ON SITE_pcornet.ob_smoking USING btree
    (observation_id)
    TABLESPACE pg_default;

commit;
begin;
create table SITE_pcornet.ob_tobacco_data as
(
    select ob_tobacco.person_id,ob_tobacco.visit_occurrence_id, ob_tobacco.provider_id, ob_tobacco.observation_date, ob_tobacco.value_as_concept_id, ob_tobacco_type.observation_concept_id as obs_concept_id_typ, 
	ob_smoking.observation_concept_id as obs_concept_id_smk,ob_tobacco.observation_concept_id, ob_tobacco.observation_datetime, ob_tobacco.tobacco, ob_tobacco_type.tobacco_type, ob_smoking.smoking, value_as_string,
	ob_tobacco.observation_id, ob_tobacco.observation_source_value,ob_tobacco.qualifier_concept_id,ob_tobacco.site, ob_tobacco.qualifier_source_value
	from SITE_pcornet.ob_tobacco
	left join SITE_pcornet.ob_tobacco_type on  ob_tobacco.fact_id_2 = ob_tobacco_type.observation_id
    left join SITE_pcornet.ob_smoking on ob_tobacco.fact_id_2 = ob_smoking.observation_id
);

commit; 

--  drop table SITE_pcornet.vital_extract;

begin;
create table SITE_pcornet.vital_extract_htwt as
select distinct
ms.person_id, ms.visit_occurrence_id, ms.measurement_date, ms.measurement_datetime,  
ms_ht.value_as_number as value_as_number_ht,  ms_wt.value_as_number as  value_as_number_wt,
ms_bmi.value_as_number as value_as_number_original_bmi,
ms.site
FROM SITE_pcornet.ms
left join SITE_pcornet.ms_ht on ms.visit_occurrence_id = ms_ht.visit_occurrence_id
and ms.measurement_datetime = ms_ht.measurement_datetime 
left join SITE_pcornet.ms_wt on ms.visit_occurrence_id = ms_wt.visit_occurrence_id
and ms.measurement_datetime = ms_wt.measurement_datetime 
left join SITE_pcornet.ms_bmi on ms.visit_occurrence_id = ms_bmi.visit_occurrence_id
and ms.measurement_datetime = ms_bmi.measurement_datetime
;
commit;

begin;
create table SITE_pcornet.vital_extract_diasys as
select distinct
ms.person_id, ms.visit_occurrence_id, ms.measurement_date, ms.measurement_datetime,  
value_as_number_ht, value_as_number_wt,
ms_dia.value_as_number as value_as_number_diastolic,
ms_sys.value_as_number as value_as_number_systolic,
value_as_number_original_bmi,
ms_sys.measurement_concept_id as measurement_concept_id_sys,
ms_sys.measurement_source_value as measurement_source_value_sys, 
ms_dia.measurement_source_value as measurement_source_value_dia, 
ms.site
FROM SITE_pcornet.vital_extract_htwt ms
left join SITE_pcornet.ms_sys on ms.visit_occurrence_id = ms_sys.visit_occurrence_id
and ms.measurement_datetime = ms_sys.measurement_datetime
left join SITE_pedsnet.fact_relationship fr1 on fr1.fact_id_1 = ms_sys.measurement_id AND fr1.domain_concept_id_1=21 AND fr1.domain_concept_id_2=21
left join SITE_pcornet.ms_dia on ms.visit_occurrence_id = ms_dia.visit_occurrence_id
and ms_dia.measurement_id= fr1.fact_id_2;
commit;

begin;
drop table SITE_pcornet.vital_extract_htwt;
commit;

begin;
create table SITE_pcornet.vital_extract as
select distinct
ms.person_id, ms.visit_occurrence_id, ms.measurement_date, ms.measurement_datetime,  
value_as_number_ht, value_as_number_wt, value_as_number_diastolic,value_as_number_systolic,value_as_number_original_bmi,
measurement_concept_id_sys,tobacco,tobacco_type,smoking,measurement_source_value_sys, measurement_source_value_dia, 
ms.site
FROM SITE_pcornet.vital_extract_diasys ms
left join SITE_pcornet.ob_tobacco_data on ms.visit_occurrence_id = ob_tobacco_data.visit_occurrence_id
and ms.measurement_datetime = ob_tobacco_data.observation_datetime
where coalesce(value_as_number_ht, value_as_number_wt, value_as_number_diastolic, value_as_number_systolic, value_as_number_original_bmi) is not null;
commit;

begin;
drop table SITE_pcornet.vital_extract_diasys;
commit;

begin;
DELETE from SITE_pcornet.vital_extract
where person_id not in (select person_id from SITE_pcornet.person_visit_start2001);

DELETE from SITE_pcornet.vital_extract
where visit_occurrence_id not in (select visit_id from SITE_pcornet.person_visit_start2001);
commit;

begin;
--- transform 
create table SITE_pcornet.vital_transform as
SELECT distinct
cast(person_id as text) as patid,
cast(visit_occurrence_id as text) as encounterid,
cast(cast(date_part('year', measurement_date) as text)||'-'||lpad(cast(date_part('month', measurement_date) as text),2,'0')||'-'||lpad(cast(date_part('day', measurement_date) as text),2,'0') as date) 
     as measure_date,
lpad(cast(date_part('hour', measurement_datetime) as text),2,'0')||':'||lpad(cast(date_part('minute', measurement_datetime) as text),2,'0') as measure_time,
'HC' as vital_source, -- defaulting to 'HC'
-- In the meanwhile, we will ask the sites whether they can differentiate between HC and HD and will make any applicable changes to PEDSnet conventions 2.1
    (value_as_number_ht*0.393701) as ht, -- cm to inch conversion
    (value_as_number_wt*2.20462) as wt, -- kg to pound conversion
value_as_number_diastolic as diastolic,
value_as_number_systolic as systolic,
value_as_number_original_bmi as original_bmi,
tobacco,
tobacco_type,
smoking,
measurement_source_value_dia as raw_diastolic,
measurement_source_value_sys as raw_systolic,
coalesce(m.target_concept,'OT') as bp_position, 
null as raw_bp_position, -- Charlie saying not to capture this even though some sties may have store this explicitly - too much effort for populating a raw field 
site as site
FROM SITE_pcornet.vital_extract
left join pcornet_maps.pedsnet_pcornet_valueset_map m on cast(measurement_concept_id_sys as text) = m.source_concept_id
	AND m.source_concept_class='BP Position'; 
commit;


--- loading
begin;
insert into SITE_pcornet.vital(
            vitalid, patid, encounterid, measure_date, measure_time, vital_source, 
            ht, wt, diastolic, systolic, original_bmi, bp_position, 
	    tobacco, tobacco_type, smoking
            ,raw_diastolic, raw_systolic, raw_bp_position,site)
select nextval('sq_vitalid') as vitalid, patid, encounterid, measure_date, measure_time, vital_source,
            ht, wt, diastolic, systolic, original_bmi, bp_position, 
	    tobacco, tobacco_type, smoking
            ,raw_diastolic, raw_systolic, raw_bp_position,site
from SITE_pcornet.vital_transform;
commit;
