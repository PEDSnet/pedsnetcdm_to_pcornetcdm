

-- Visit occurrence -> encounter
-- Observation_period -> Enrollment
-- Changes from previous version:
---- Change Concept ID for Residential Facility for Admitting source to 44814680'
---- Replace specific concept_id for No information/Unknown/Other with generic concept id
---- Change source column for raw_ target columns from value_as_concept_id to observation_source_value
---- changed the logic to extract DRGs (only MS-DRGs are needed by PCORnet)
set search_path to pedsnet_cdm;

insert into pcornet_cdm.encounter (
            patid, encounterid, admit_date, admit_time, discharge_date, discharge_time,
            providerid, facility_location, enc_type, facilityid, discharge_disposition,
            discharge_status, drg, drg_type, admitting_source, raw_enc_type,
            raw_discharge_disposition, raw_discharge_status, raw_drg_type,
            raw_admitting_source)
WITH  o1 as (select distinct person_id,visit_occurrence_id,value_as_concept_id, observation_source_value from observation where observation_concept_id = 44813951)
     ,o2 as (select distinct person_id,visit_occurrence_id, value_as_string
		from observation
		where observation_concept_id = 3040464 and observation_date >'2007-10-01'
			and value_as_string in (select concept_code from concept where invalid_reason is null and concept_class_id = 'MS-DRG' and vocabulary_id='DRG' )
		)
     ,o3 as (select distinct person_id,visit_occurrence_id, value_as_concept_id,observation_source_value from observation where observation_concept_id = 4137274)
     ,o4 as (select distinct value_as_concept_id, visit_occurrence_id, person_id,observation_source_value from observation where observation_concept_id = 4145666)
select distinct
	cast(v.person_id as text) as pat_id,
	cast(v.visit_occurrence_id as text) as encounterid ,
	cast(cast(date_part('year', visit_start_date) as text)||'-'||lpad(cast(date_part('month', visit_start_date) as text),2,'0')||'-'||lpad(cast(date_part('day', visit_start_date) as text),2,'0')
	as date) as admit_date,
    date_part('hour',visit_start_date)||':'||date_part('minute',visit_start_date) as admit_time,
	cast(cast(date_part('year', visit_end_date) as text)||'-'||lpad(cast(date_part('month', visit_end_date) as text),2,'0')||'-'||lpad(cast(date_part('day', visit_end_date) as text),2,'0')
	 as date) as discharge_date,
	date_part('hour',visit_end_date)||':'||date_part('minute',visit_end_date) as discharge_time,
	v.provider_id as providerid,
	left(l.zip,3) as facility_location,
    coalesce(m1.target_concept,'OT') as enc_type,
    v.care_site_id as facilityid,
    min(case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else case when o1.person_id is null then 'NI' else coalesce(m2.target_concept,'OT') end end) as discharge_disposition, -- Colorado having multiple discharge dispoition
    min(case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else case when o3.person_id is null then 'NI' else coalesce(m3.target_concept,'OT') end end) as discharge_status,
    min(case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else o2.value_as_string end) as drg, -- -records having multiple DRGs
	case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else case when visit_start_date<'2007-10-01' then '01' else '02' end end as drg_type,
	case when o4.person_id is null then 'NI' else coalesce(m4.target_concept,'OT') end as admitting_source,
	v.visit_source_value as raw_enc_type,
	min(case when o1.person_id is null then null else o1.observation_source_value end) as raw_discharge_disposition, -- having multiple records for Colorado
	min(case when o3.person_id is null then null else o3.observation_source_value end) as raw_discharge_status,
	null as raw_drg_type,
	min(case when o4.person_id is null then null else o4.observation_source_value end) as raw_admitting_source
from
	pedsnet_cdm.visit_occurrence v
	left join care_site c on v.care_site_id = c.care_site_id
	left join location l on c.location_id = l.location_id
	left join o1 on v.visit_occurrence_id = o1.visit_occurrence_id
	left join o2 on v.visit_occurrence_id = o2.visit_occurrence_id
	left join o3 on v.visit_occurrence_id = o3.visit_occurrence_id
	left join o4 on v.visit_occurrence_id = o4.visit_occurrence_id
	left join pcornet_cdm.cz_omop_pcornet_concept_map m1 on case when v.visit_concept_id is null AND m1.source_concept_id is null then true else 	cast(v.visit_concept_id as text)= m1.source_concept_id end and m1.source_concept_class='Encounter type'
	left join pcornet_cdm.cz_omop_pcornet_concept_map m2 on case when o1.value_as_concept_id is null AND m2.value_as_concept_id is null then true else o1.value_as_concept_id = m2.value_as_concept_id end and m2.source_concept_class='Discharge disposition'
	left join pcornet_cdm.cz_omop_pcornet_concept_map m3 on case when o3.value_as_concept_id is null AND m3.value_as_concept_id is null then true else o3.value_as_concept_id = m3.value_as_concept_id end and m3.source_concept_class='Discharge status'
	left join pcornet_cdm.cz_omop_pcornet_concept_map m4 on case when o4.value_as_concept_id is null AND m4.value_as_concept_id is null then true else o4.value_as_concept_id = m4.value_as_concept_id end and m4.source_concept_class='Admitting source'
group by
    v.person_id,
    v.visit_occurrence_id,
    cast(date_part('year', visit_start_date) as text)||'-'||lpad(cast(date_part('month', visit_start_date) as text),2,'0')||'-'||lpad(cast(date_part('day',visit_start_date) as text),2,'0'),
    date_part('hour',visit_start_date)||':'||date_part('minute',visit_start_date),
    cast(date_part('year', visit_end_date) as text)||'-'||lpad(cast(date_part('month', visit_end_date) as text),2,'0')||'-'||lpad(cast(date_part('day', visit_end_date) as text),2,'0'),
    date_part('hour',visit_end_date)||':'||date_part('minute',visit_end_date),
    v.provider_id,
    left(l.zip,3),
    coalesce(m1.target_concept,'OT'),
    v.care_site_id,
    --case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else case when o1.person_id is null then 'NI' else coalesce(m2.target_concept,'OT') end end,
    --case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else o2.value_as_string end,
    case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else case when visit_start_date<'2007-10-01' then '01' else '02' end end,
    case when o4.person_id is null then 'NI' else coalesce(m4.target_concept,'OT') end,
    v.visit_concept_id,
   -- case when o1.person_id is null then null else cast(o1.observation_source_value as text) end,
    case when o4.person_id is null then null else cast(o4.observation_source_value as text) end
