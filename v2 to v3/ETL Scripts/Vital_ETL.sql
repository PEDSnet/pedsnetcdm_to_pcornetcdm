-- observation --> vital 
-- Changes from previous version:
---- Change source table from observation to measurement
---- Populate vital_source, raw vital source, raw diastolic and raw systolic
---- Use fact_relationship to tie diastolic BP and systolic PB
insert into pcornet_cdm.vital(
            patid, encounterid, measure_date, measure_time, vital_source, 
            ht, wt, diastolic, systolic, original_bmi, bp_position, 
            raw_diastolic, raw_systolic, raw_bp_position)
 WITH
ms as (select distinct person_id, visit_occurrence_id,measurement_date  from measurement where measurement_concept_id IN ('3023540','3013762','3034703','3019962','3013940','3012888','3018586','3035856','3009395','3004249','3038553')),
ms_ht as (select distinct measurement_id, visit_occurrence_id, measurement_date, value_as_number  from measurement where measurement_concept_id = '3023540'),
ms_wt as (select distinct measurement_id,visit_occurrence_id, measurement_date, value_as_number  from measurement where measurement_concept_id = '3013762'),
ms_bmi as (select distinct measurement_id,visit_occurrence_id, measurement_date, value_as_number  from measurement where measurement_concept_id = '3038553'),
ms_sys as (select distinct measurement_id, visit_occurrence_id, measurement_date, value_as_number, value_as_concept_id, measurement_concept_id,measurement_source_value from measurement where measurement_concept_id in ('3018586','3035856','3009395','3004249')),
ms_dia as (select distinct measurement_id, visit_occurrence_id, measurement_date, measurement_type_concept_id, value_as_number, measurement_source_value from measurement where measurement_concept_id in ('3034703','3019962','3013940','3012888')),
ms_vs as (select distinct measurement_id, visit_occurrence_id, measurement_date, measurement_type_concept_id from measurement where measurement_type_concept_id IN ('44814721'))
SELECT 
cast(ms.person_id as text) as patid,
cast(ms.visit_occurrence_id as text) as encounterid,
cast(cast(date_part('year', ms.measurement_date) as text)||'-'||lpad(cast(date_part('month', ms.measurement_date) as text),2,'0')||'-'||lpad(cast(date_part('day', ms.measurement_date) as text),2,'0') as date) 
     as measure_date,
lpad(cast(date_part('hour', ms.measurement_date) as text),2,'0')||':'||lpad(cast(date_part('minute', ms.measurement_date) as text),2,'0') as measure_time,
case when ms_vs.measurement_type_concept_id is not null then 'PR' else 'NI' end as vital_source,
    (ms_ht.value_as_number*0.393701) as ht, -- cm to inch conversion
    (ms_wt.value_as_number*2.20462) as wt, -- kg to pound conversion
ms_dia.value_as_number as diastolic,
ms_sys.value_as_number as systolic,
ms_bmi.value_as_number as original_bmi,
coalesce(m.target_concept,'OT') as bp_position,
ms_dia.measurement_source_value as raw_diastolic,
ms_sys.measurement_source_value as raw_systolic,
null as raw_bp_position
FROM 
ms
left join ms_ht on ms.visit_occurrence_id = ms_ht.visit_occurrence_id 
and ms.measurement_date = ms_ht.measurement_date 
left join ms_wt on ms.visit_occurrence_id = ms_wt.visit_occurrence_id 
and ms. measurement_date = ms_wt.measurement_date 
left join ms_vs on ms. visit_occurrence_id = ms_vs.visit_occurrence_id 
and ms.measurement_date = ms_vs.measurement_date
left join ms_sys on ms.visit_occurrence_id = ms_sys.visit_occurrence_id 
and ms.measurement_date = ms_sys.measurement_date
left join fact_relationship fr1 on fr1.fact_id_1 = ms_sys.measurement_id AND fr1.domain_concept_id_1=21 AND fr1.domain_concept_id_2=21
left join ms_dia on ms.visit_occurrence_id = ms_dia.visit_occurrence_id 
and ms_dia.measurement_id = fr1.fact_id_2
left join ms_bmi on ms.visit_occurrence_id = ms_bmi.visit_occurrence_id 
and ms.measurement_date = ms_bmi.measurement_date 
left join pcornet_cdm.cz_omop_pcornet_concept_map m on ms_sys.measurement_concept_id = m.source_concept_id AND m.source_concept_class='BP Position'
where coalesce(ms_ht.value_as_number, ms_wt.value_as_number, ms_dia.value_as_number, ms_sys.value_as_number, ms_bmi.value_as_number) is not null;

