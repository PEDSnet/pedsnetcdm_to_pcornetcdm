begin;
ALTER TABLE SITE_pcornet.vital ALTER original_bmi SET DATA TYPE NUMERIC(20,8);

drop sequence if exists SITE_pcornet.sq_vitalid;
create sequence SITE_pcornet.sq_vitalid start 1;
commit;

-- extract all fields 
begin;
create table SITE_pcornet.ms_ht as
(
    select  distinct person_id, site, measurement_id,visit_occurrence_id, measurement_date, measurement_datetime, value_as_number
	,  measurement_concept_id,measurement_source_value  
	from SITE_pedsnet.measurement
	where measurement_concept_id = '3023540';
);

CREATE INDEX idx_msht_mdtm
    ON SITE_pcornet.ms_ht USING btree
    (measurement_datetime)
    TABLESPACE pg_default;

CREATE INDEX idx_msht_visid
   ON SITE_pcornet.ms_ht USING btree
   (visit_occurrence_id)
   TABLESPACE pg_default;

create table SITE_pcornet.ms_wt as
(
   select distinct person_id, site, measurement_id,visit_occurrence_id, measurement_date, measurement_datetime, value_as_number
	,  measurement_concept_id,measurement_source_value
	from SITE_pedsnet.measurement
	where measurement_concept_id = '3013762'
);

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
    select distinct person_id, site, measurement_id,visit_occurrence_id,
	measurement_date, measurement_datetime, value_as_number,  measurement_concept_id,measurement_source_value
    from SITE_pedsnet.measurement
    where measurement_concept_id = '3038553'
);

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
   select distinct person_id, site, measurement_id, visit_occurrence_id,
		measurement_date, measurement_datetime, value_as_number,  measurement_concept_id,measurement_source_value
   from SITE_pedsnet.measurement
   where measurement_concept_id in ('3018586','3035856','3009395','3004249')
);

CREATE INDEX idx_mssy_mdtm
    ON SITE_pcornet.ms_sys USING btree
    (measurement_datetime)
    TABLESPACE pg_default;

CREATE INDEX idx_mssy_visid
    ON SITE_pcornet.ms_sys USING btree
    (visit_occurrence_id)
    TABLESPACE pg_default;

create table SITE_pcornet.ms_dia as
(
    select distinct person_id, site, measurement_id,
		visit_occurrence_id, measurement_date, measurement_datetime, value_as_number, 
			 measurement_concept_id,measurement_source_value
	from SITE_pedsnet.measurement
	where measurement_concept_id in ('3034703','3019962','3013940','3012888')
);

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
	select * from SITE_pcornet.ms_ht
	UNION 
	select * from SITE_pcornet.ms_wt
	UNION 
	select * from SITE_pcornet.ms_bmi
	UNION 
	select * from SITE_pcornet.ms_sys
	UNION 
	select * from SITE_pcornet.ms_dia;

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
    select distinct observation_id, visit_occurrence_id, observation_date, observation_datetime,
           coalesce(m1.target_concept,'OT') as tobacco, f.fact_id_2
	from SITE_pedsnet.observation o1
	left join pcornet_maps.pedsnet_pcornet_valueset_map m1 on cast(o1.value_as_concept_id as text) = m1.source_concept_id
	join chop_pedsnet.fact_relationship f on o1.observation_id = f.fact_id_1
	where observation_concept_id IN ('4005823')
);
CREATE INDEX idx_tbc_factid
    ON SITE_pcornet.ob_tobacco USING btree
    (fact_id_2)
    TABLESPACE pg_default;
commit;
begin;
create table SITE_pcornet.ob_tobacco_type as
(
    select distinct observation_id, visit_occurrence_id, observation_date, observation_datetime, coalesce(m2.target_concept,'OT') as tobacco_type
	from SITE_pedsnet.observation o1 
	left join pcornet_maps.pedsnet_pcornet_valueset_map m2 on cast(o1.value_as_concept_id as text) = m2.source_concept_id
	where observation_concept_id IN ('4219336')
);
CREATE INDEX idx_toty_obsid
    ON SITE_pcornet.ob_tobacco_type USING btree
    (tobacco_type COLLATE pg_catalog."default")
    TABLESPACE pg_default;
commit;
begin;
create table SITE_pcornet.ob_smoking as
(
    select distinct observation_id, visit_occurrence_id, observation_date, observation_datetime, coalesce(m3.target_concept,'OT') as smoking
	from SITE_pedsnet.observation o1 left join pcornet_maps.pedsnet_pcornet_valueset_map m3 on cast(o1.value_as_concept_id as text)= m3.source_concept_id
	where observation_concept_id IN ('4275495')
);
CREATE INDEX idx_tosmk_obsid
    ON SITE_pcornet.ob_smoking USING btree
    (observation_id)
    TABLESPACE pg_default;

commit;
begin;
create table SITE_pcornet.ob_tobacco_data as
(
    select ob_tobacco.visit_occurrence_id, ob_tobacco.observation_date, ob_tobacco.observation_datetime, ob_tobacco.tobacco, ob_tobacco_type.tobacco_type, ob_smoking.smoking
	from SITE_pcornet.ob_tobacco
	left join chop_pcornet.ob_tobacco_type on  ob_tobacco.fact_id_2 = ob_tobacco_type.observation_id
    left join chop_pcornet.ob_smoking on ob_tobacco.fact_id_2 = ob_smoking.observation_id
);
commit; 

--  drop table SITE_pcornet.vital_extract;

begin;
create table SITE_pcornet.vital_extract as
select distinct
ms.person_id, ms.visit_occurrence_id,  ms.measurement_date, ms.measurement_datetime,  
ms_ht.value_as_number as value_as_number_ht,  ms_wt.value_as_number as  value_as_number_wt,
ms_dia.value_as_number as value_as_number_diastolic,
ms_sys.value_as_number as value_as_number_systolic,
ms_bmi.value_as_number as value_as_number_original_bmi,
ms_sys.measurement_concept_id as measurement_concept_id_sys,
tobacco,
tobacco_type,
smoking,
ms_sys.measurement_source_value as measurement_source_value_sys, 
ms_dia.measurement_source_value as measurement_source_value_dia, 
ms.site
FROM 
SITE_pcornet.ms
left join SITE_pcornet.ms_ht on ms.visit_occurrence_id = ms_ht.visit_occurrence_id
and ms.measurement_datetime = ms_ht.measurement_datetime 
left join SITE_pcornet.ms_wt on ms.visit_occurrence_id = ms_wt.visit_occurrence_id
and ms.measurement_datetime = ms_wt.measurement_datetime 
left join SITE_pcornet.ms_sys on ms.visit_occurrence_id = ms_sys.visit_occurrence_id
and ms.measurement_datetime = ms_sys.measurement_datetime
left join SITE_pedsnet.fact_relationship fr1 on fr1.fact_id_1 = ms_sys.measurement_id AND fr1.domain_concept_id_1=21 AND fr1.domain_concept_id_2=21
left join SITE_pcornet.ms_dia on ms.visit_occurrence_id = ms_dia.visit_occurrence_id
and ms_dia.measurement_id = fr1.fact_id_2
left join SITE_pcornet.ms_bmi on ms.visit_occurrence_id = ms_bmi.visit_occurrence_id
and ms.measurement_datetime = ms_bmi.measurement_datetime 
left join SITE_pcornet.ob_tobacco_data on ms.visit_occurrence_id = ob_tobacco_data.visit_occurrence_id
and ms.measurement_datetime = ob_tobacco_data.observation_datetime
where coalesce(ms_ht.value_as_number, ms_wt.value_as_number, ms_dia.value_as_number, ms_sys.value_as_number, ms_bmi.value_as_number) is not null
	  and EXTRACT(YEAR FROM ms.measurement_date) >= 2001 and
      ms.person_id in (select person_id from SITE_pcornet.person_visit_start2001) and
      ms.visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001);
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
FROM 
SITE_pcornet.vital_extract
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
select nextval('SITE_pcornet.sq_vitalid') as vitalid, patid, encounterid, measure_date, measure_time, vital_source,
            ht, wt, diastolic, systolic, original_bmi, bp_position, 
	    tobacco, tobacco_type, smoking
            ,raw_diastolic, raw_systolic, raw_bp_position,site
from SITE_pcornet.vital_transform;
commit;
