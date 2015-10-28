---------- Vital query
-- observation --> vital
-- Changes from previous version:
---- Change source table from observation to measurement
---- Populate vital_source, raw vital source, raw diastolic and raw systolic
---- Use fact_relationship to tie diastolic BP and systolic PB
--- Not asked will be skipped and will be incorporated in the next ETL cycle since it is a meaningful use concept.(v2.1)
--- The query is agnostic to the concept id of the relationship.
-- We use a concatenated PK (based on ht, wt, dia, sys, bmi measurement ids


--set role pcor_et_user;

--drop table if exists pcornet_cdm.vital;

set search_path to pedsnet_cdm;

insert into pcornet_cdm.vital(
            vitalid, patid, encounterid, measure_date, measure_time, vital_source,
            ht, wt, diastolic, systolic, original_bmi, bp_position,
	    tobacco, tobacco_type, smoking
            ,raw_diastolic, raw_systolic, raw_bp_position)
 WITH
ms as (select distinct person_id, visit_occurrence_id,measurement_date, measurement_time  from measurement where measurement_concept_id IN ('3023540','3013762','3034703','3019962','3013940','3012888','3018586','3035856','3009395','3004249','3038553')),
ms_ht as (select distinct measurement_id, visit_occurrence_id, measurement_date, measurement_time, value_as_number  from measurement where measurement_concept_id = '3023540'),
ms_wt as (select distinct measurement_id,visit_occurrence_id, measurement_date, measurement_time, value_as_number  from measurement where measurement_concept_id = '3013762'),
ms_bmi as (select distinct measurement_id,visit_occurrence_id, measurement_date, measurement_time, value_as_number  from measurement where measurement_concept_id = '3038553'),
ms_sys as (select distinct measurement_id, visit_occurrence_id, measurement_date, measurement_time, value_as_number, value_as_concept_id, measurement_concept_id,measurement_source_value from measurement where measurement_concept_id in ('3018586','3035856','3009395','3004249')),
ms_dia as (select distinct measurement_id, visit_occurrence_id, measurement_date, measurement_time, measurement_type_concept_id, value_as_number, measurement_source_value from measurement where measurement_concept_id in ('3034703','3019962','3013940','3012888')),
ms_vs as (select distinct measurement_id, visit_occurrence_id, measurement_date, measurement_time, measurement_type_concept_id from measurement where measurement_type_concept_id IN ('44814721')),
ob_tobacco as ( select distinct observation_id, visit_occurrence_id, observation_date, observation_time,coalesce(m1.target_concept,'OT') as tobacco
	from observation o1 left join pcornet_cdm.cz_omop_pcornet_concept_map m1 on cast(o1.value_as_concept_id as text) = m1.source_concept_id
	where observation_concept_id IN ('4005823')),
ob_tobacco_type as (select distinct observation_id, visit_occurrence_id, observation_date, observation_time, coalesce(m2.target_concept,'OT') as tobacco_type
	from observation o1
	left join pcornet_cdm.cz_omop_pcornet_concept_map m2 on cast(o1.value_as_concept_id as text) = m2.source_concept_id
	where observation_concept_id IN ('4219336')),
ob_smoking as (select distinct observation_id, visit_occurrence_id, observation_date, observation_time, coalesce(m3.target_concept,'OT') as smoking
	from observation o1 left join pcornet_cdm.cz_omop_pcornet_concept_map m3 on cast(o1.value_as_concept_id as text)= m3.source_concept_id
	where observation_concept_id IN ('4275495')),
ob_tobacco_data as (select ob_tobacco.visit_occurrence_id, ob_tobacco.observation_date, ob_tobacco.observation_time, ob_tobacco.tobacco, ob_tobacco_type.tobacco_type, ob_smoking.smoking
	from ob_tobacco
	left join fact_relationship fr2 on ob_tobacco.observation_id = fr2.fact_id_1
	join ob_tobacco_type on fr2.fact_id_2 = ob_tobacco_type.observation_id
	left join fact_relationship fr3 on ob_tobacco.observation_id = fr3.fact_id_1
	join ob_smoking on fr3.fact_id_2 = ob_smoking.observation_id)
SELECT distinct
 coalesce(cast(ms_ht.measurement_id as text),'')||'-'||coalesce(cast(ms_wt.measurement_id as text),'')
 ||'-'||coalesce(cast(ms_sys.measurement_id as text),'')||
 '-'||coalesce(cast(ms_dia.measurement_id as text),'')||'-'||coalesce(cast(ms_bmi.measurement_id as text),'')||'-'||coalesce(cast(ms.person_id as text),'') as vitalid,
cast(ms.person_id as text) as patid,
cast(ms.visit_occurrence_id as text) as encounterid,
cast(cast(date_part('year', ms.measurement_date) as text)||'-'||lpad(cast(date_part('month', ms.measurement_date) as text),2,'0')||'-'||lpad(cast(date_part('day', ms.measurement_date) as text),2,'0') as date)
     as measure_date,
lpad(cast(date_part('hour', ms.measurement_time) as text),2,'0')||':'||lpad(cast(date_part('minute', ms.measurement_time) as text),2,'0') as measure_time,
'HC' as vital_source, -- defaulting to 'HC'
-- In the meanwhile, we will ask the sites whether they can differentiate between HC and HD and will make any applicable changes to PEDSnet conventions 2.1
    (ms_ht.value_as_number*0.393701) as ht, -- cm to inch conversion
    (ms_wt.value_as_number*2.20462) as wt, -- kg to pound conversion
ms_dia.value_as_number as diastolic,
ms_sys.value_as_number as systolic,
ms_bmi.value_as_number as original_bmi,
coalesce(m.target_concept,'OT') as bp_position,
ob_tobacco_data.tobacco as tobacco,
ob_tobacco_data.tobacco_type as tobacco_type,
ob_tobacco_data.smoking as smoking,
ms_dia.measurement_source_value as raw_diastolic,
ms_sys.measurement_source_value as raw_systolic,
null as raw_bp_position
FROM
ms
left join ms_ht on ms.visit_occurrence_id = ms_ht.visit_occurrence_id
and ms.measurement_time = ms_ht.measurement_time
left join ms_wt on ms.visit_occurrence_id = ms_wt.visit_occurrence_id
and ms.measurement_time = ms_wt.measurement_time
left join ms_vs on ms. visit_occurrence_id = ms_vs.visit_occurrence_id
and ms.measurement_time = ms_vs.measurement_time
left join ms_sys on ms.visit_occurrence_id = ms_sys.visit_occurrence_id
and ms.measurement_time = ms_sys.measurement_time
left join fact_relationship fr1 on fr1.fact_id_1 = ms_sys.measurement_id AND fr1.domain_concept_id_1=21 AND fr1.domain_concept_id_2=21
left join ms_dia on ms.visit_occurrence_id = ms_dia.visit_occurrence_id
and ms_dia.measurement_id = fr1.fact_id_2
left join ms_bmi on ms.visit_occurrence_id = ms_bmi.visit_occurrence_id
and ms.measurement_time = ms_bmi.measurement_time
left join pcornet_cdm.cz_omop_pcornet_concept_map m on cast(ms_sys.measurement_concept_id as text) = m.source_concept_id AND m.source_concept_class='BP Position'
left join ob_tobacco_data on ms.visit_occurrence_id = ob_tobacco_data.visit_occurrence_id
and ms.measurement_time = ob_tobacco_data.observation_time
where coalesce(ms_ht.value_as_number, ms_wt.value_as_number, ms_dia.value_as_number, ms_sys.value_as_number, ms_bmi.value_as_number) is not null
