-- Person -> Demographic
-- Changes from previous version:
-- Change these two rows from Biobank flag mappings

-- N|Biobank flag|4001345|44814650|No information
-- N|Biobank flag|4001345|44814653|Unknown

-- Reason: Use generic concept ID for No information and Unknown.

insert into pcornet.demographic (patid, birth_date, birth_time, sex, hispanic, race, biobank_flag, raw_sex, raw_hispanic, raw_race)
select distinct 
	cast(p.person_id as text) as pat_id,
	cast(year_of_birth as text)
        ||(case when month_of_birth is null then '-01' else '-'||lpad(cast(month_of_birth as text),2,'0') end)
        ||(case when day_of_birth is null then '-01' else '-'||lpad(cast(day_of_birth as text),2,'0') end)
        as birth_date,
	date_part('hour',pn_time_of_birth)||':'||date_part('minute',pn_time_of_birth) as birth_time,
	coalesce (m1.target_concept,'OT') as Sex,
	coalesce (m2.target_concept,'OT') as Hispanic,
	coalesce (m3.target_concept,'OT') as Race,
	case when o.person_id is null then 'N' else coalesce (m4.target_concept,'N') end as Biobank_flag,
	gender_source_value,
	ethnicity_source_value,
	race_source_value
from
	omop.person p
	left join omop.observation o on p.person_id = o.person_id and observation_concept_id = 4001345
	left join cz.cz_omop_pcornet_concept_map m1 on case when p.gender_concept_id is null AND m1.source_concept_id is null then true else p.gender_concept_id = m1.source_concept_id end and m1.source_concept_class='Gender'
	left join cz.cz_omop_pcornet_concept_map m2 on case when p.ethnicity_concept_id is null AND m2.source_concept_id is null then true else p.ethnicity_concept_id = m2.source_concept_id end and m2.source_concept_class='Hispanic'
	left join cz.cz_omop_pcornet_concept_map m3 on case when p.race_concept_id is null AND m3.source_concept_id is null then true else p.race_concept_id = m3.source_concept_id end and m3.source_concept_class = 'Race'
	left join cz.cz_omop_pcornet_concept_map m4 on case when o.value_as_concept_id is null AND m4.value_as_concept_id is null then true else o.value_as_concept_id=m4.value_as_concept_id end and m4.source_concept_class = 'Biobank flag'

-- Observation_period -> Enrollment
-- Changes from previous version:
-- Change these two rows from Biobank flag mappings

-- N|Chart availability|4001345|44814650|No information
-- N|Chart availability|4001345|44814653|Unknown

-- Reason: Use generic concept ID for No information and Unknown.

insert into pcornet.enrollment (patid, enr_start_date, enr_end_date, chart, enr_basis)
select distinct 
	cast(op.person_id as text) as pat_id,
	cast(date_part('year', observation_period_start_date) as text)||'-'||lpad(cast(date_part('month', observation_period_start_date) as text),2,'0')||'-'||lpad(cast(date_part('day', observation_period_start_date) as text),2,'0') as enr_start_date,
	cast(date_part('year', observation_period_end_date) as text)||'-'||lpad(cast(date_part('month', observation_period_end_date) as text),2,'0')||'-'||lpad(cast(date_part('day', observation_period_end_date) as text),2,'0') as enr_end_date,
	case when o.person_id is null then 'N' else coalesce(m1.target_concept,'N') end as chart,
	'E' as ENR_basis
from
	omop.observation_period op
	left join omop.observation o on op.person_id = o.person_id and observation_concept_id = 4030450
	left join cz.cz_omop_pcornet_concept_map m1 on case when o.value_as_concept_id is null AND m1.value_as_concept_id is null then true else o.value_as_concept_id = m1.value_as_concept_id end and m1.source_concept_class = 'Chart availability'

-- Visit occurrence -> encounter
-- Observation_period -> Enrollment
-- Changes from previous version:
---- Change Concept ID for Residential Facility for Admitting source to 44814680'
---- Replace specific concept_id for No information/Unknown/Other with generic concept id
---- Change source column for raw_ target columns from value_as_concept_id to observation_source_value

insert into pcornet.encounter (
            patid, encounterid, admit_date, admit_time, discharge_date, discharge_time, 
            providerid, facility_location, enc_type, facilityid, discharge_disposition, 
            discharge_status, drg, drg_type, admitting_source, raw_enc_type, 
            raw_discharge_disposition, raw_discharge_status, raw_drg_type, 
            raw_admitting_source)
WITH  o1 as (select distinct person_id,visit_occurrence_id,value_as_concept_id from omop.observation where observation_concept_id = 44813951)
     ,o2 as (select distinct person_id,visit_occurrence_id, value_as_string from omop.observation where observation_concept_id = 3040464)
     ,o3 as (select distinct person_id,visit_occurrence_id, value_as_concept_id from omop.observation where observation_concept_id = 4137274)
     ,o4 as (select distinct value_as_concept_id, visit_occurrence_id, person_id from omop.observation where observation_concept_id = 4145666)
select distinct 
	cast(v.person_id as text) as pat_id,
	cast(v.visit_occurrence_id as text) as encounterid ,
	cast(date_part('year', visit_start_date) as text)||'-'||lpad(cast(date_part('month', visit_start_date) as text),2,'0')||'-'||lpad(cast(date_part('day', 	visit_start_date) as text),2,'0') as admit_date,
    date_part('hour',visit_start_date)||':'||date_part('minute',visit_start_date) as admit_time,
	cast(date_part('year', visit_end_date) as text)||'-'||lpad(cast(date_part('month', visit_end_date) as text),2,'0')||'-'||lpad(cast(date_part('day', visit_end_date) as text),2,'0') as discharge_date,
	date_part('hour',visit_end_date)||':'||date_part('minute',visit_end_date) as discharge_time,
	v.provider_id as providerid,
	left(l.zip,3) as facility_location,
    coalesce(m1.target_concept,'OT') as enc_type,
    v.care_site_id as facilityid,
    case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else case when o1.person_id is null then 'NI' else coalesce(m2.target_concept,'OT') end end as discharge_disposition,
    min(case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else case when o3.person_id is null then 'NI' else coalesce(m3.target_concept,'OT') end end) as discharge_status,
    case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else o2.value_as_string end as drg,
	case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else case when visit_start_date<'2007-10-01' then '01' else '02' end end as drg_type,
	case when o4.person_id is null then 'NI' else coalesce(m4.target_concept,'OT') end as admitting_source,
	v.visit_source_value as raw_enc_type,
	case when o1.person_id is null then null else o1.observation_source_value end as raw_discharge_disposition,
	min(case when o3.person_id is null then null else o3.observation_source_value end) as raw_discharge_status,
	null as raw_drg_type,
	case when o4.person_id is null then null else o4.observation_source_value end as raw_admitting_source
from 
	omop.visit_occurrence v
	left join omop.care_site c on v.care_site_id = c.care_site_id
	left join omop.location l on c.location_id = l.location_id
	left join o1 on v.visit_occurrence_id = o1.visit_occurrence_id 
	left join o2 on v.visit_occurrence_id = o2.visit_occurrence_id 
	left join o3 on v.visit_occurrence_id = o3.visit_occurrence_id 
	left join o4 on v.visit_occurrence_id = o4.visit_occurrence_id 
	left join cz.cz_omop_pcornet_concept_map m1 on case when v.place_of_service_concept_id is null AND m1.source_concept_id is null then true else 	v.place_of_service_concept_id = m1.source_concept_id end and m1.source_concept_class='Encounter type'
	left join cz.cz_omop_pcornet_concept_map m2 on case when o1.value_as_concept_id is null AND m2.value_as_concept_id is null then true else o1.value_as_concept_id = m2.value_as_concept_id end and m2.source_concept_class='Discharge disposition'
	left join cz.cz_omop_pcornet_concept_map m3 on case when o3.value_as_concept_id is null AND m3.value_as_concept_id is null then true else o3.value_as_concept_id = m3.value_as_concept_id end and m3.source_concept_class='Discharge status'
	left join cz.cz_omop_pcornet_concept_map m4 on case when o4.value_as_concept_id is null AND m4.value_as_concept_id is null then true else o4.value_as_concept_id = m4.value_as_concept_id end and m4.source_concept_class='Admitting source'
group by
    v.person_id,
    v.visit_occurrence_id,
    cast(date_part('year', visit_start_date) as text)||'-'||lpad(cast(date_part('month', visit_start_date) as text),2,'0')||'-'||lpad(cast(date_part('day', 	visit_start_date) as text),2,'0'),
    date_part('hour',visit_start_date)||':'||date_part('minute',visit_start_date),
    cast(date_part('year', visit_end_date) as text)||'-'||lpad(cast(date_part('month', visit_end_date) as text),2,'0')||'-'||lpad(cast(date_part('day', visit_end_date) as text),2,'0'),
    date_part('hour',visit_end_date)||':'||date_part('minute',visit_end_date),
    v.provider_id,
    left(l.zip,3),
    coalesce(m1.target_concept,'OT'),
    v.care_site_id,
    case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else case when o1.person_id is null then 'NI' else coalesce(m2.target_concept,'OT') end end,
    case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else o2.value_as_string end,
    case when coalesce(m1.target_concept,'OT') in ('AV','OA') then null else case when visit_start_date<'2007-10-01' then '01' else '02' end end,
    case when o4.person_id is null then 'NI' else coalesce(m4.target_concept,'OT') end,
    v.place_of_service_concept_id,
    case when o1.person_id is null then null else cast(o1.value_as_concept_id as text) end,
    case when o4.person_id is null then null else cast(o4.value_as_concept_id as text) end

-- condition_occurrence --> Diagnosis
-- Changes from previous version:
---- Drive dx_source from Observation.value_as_concept_id
---- Populate Pdx,raw_pdx, raw_dx_source

insert into pcornet.diagnosis(
            patid, encounterid, enc_type, admit_date, providerid, dx, dx_type, 
            dx_source, pdx, raw_dx, raw_dx_type, raw_dx_source, raw_pdx)
select distinct 
	cast(person_id as text) as patid,
	cast(visit_occurrence_id as text) encounterid,
	enc.enc_type,
	enc.admit_date,
	enc.providerid,
	-- case 1 - when source value in pcornet vocabulary 
	case when c2.vocabulary_id = 'ICD9CM' then condition_source_value
	-- case 2: when source value doesnt exist... check if concept id = non-zero and source vocab is one of the five, then include concept id (SNOMED CT code) else random number
		else case when condition_concept_id>0 then (select distinct concept_code from rz.concept c where c.concept_id = co.condition_concept_id)
		else 'NM'||cast(round(random()*10000000000000) as text) end end as dx,
	case when c2.vocabulary_id = 'ICD9CM' then '09'
		else case when condition_concept_id>0  then 'SM' else 'OT' end
	end as dx_type,
	coalesce(m1.target_concept,'OT') as dx_source,
	coalesce(m2.target_concept,'OT') as pdx,
	condition_source_value as raw_dx,
	case when co.condition_source_concept_id = '44814649' then 'OT' else c3.vocabulary_id end as raw_dx_type,
	o.observation_source_value as raw_dx_source,
	case when co.condition_type_concept_id IN ('44786627','44786629') then c4.concept_name welse NULL end as raw_pdx
from
	omop.condition_occurrence co
	join pcornet.encounter enc on cast(co.visit_occurrence_id as text)=enc.encounterid
	join rz.concept c2 on co.condition_concept_id = c2.concept_id -- Join or LEFT JOIN
	left join fact_relationship fr on domain_concept_id_1 = 19 AND fact_id_1 = co.condition_occurrence_id AND domain_concept_id_1 = 27
	join Observation o on fr.fact_id_2 = observation_concept_id AND observation_concept_id = '4021918'
	join cz.cz_omop_pcornet_concept_map m1 on case when o.value_as_concept_id is null AND m1.source_concept_id is null then true else o.value_as_concept_id = m1.source_concept_id end and m1.source_concept_class='dx_source'
	join cz.cz_omop_pcornet_concept_map m2 on case when co.condition_type_concept_id is null AND m2.source_concept_id is null then true else co.condition_type_concept_id = m2.source_concept_id end and m1.source_concept_class='pdx'
	left join rz.concept c3 on co.condition_source_concept_id = c3.concept_id
	left join rz.concept c4 on co.condition_type_concept_id = c4.concept_id 


-- procedure_occurrence -> Procedure
-- Changes from previous version:
-- No longer need source coding system info. Use source_concept_id instead.

insert into pcornet.procedure(
            patid, encounterid, enc_type, admit_date, providerid, px, px_type, 
            raw_px, raw_px_type)
select distinct 
	cast(person_id as text) as patid,
	cast(visit_occurrence_id as text) as encounterid,
	enc.enc_type as enc_type,
	enc.admit_date as admit_date,
	enc.providerid as providerid,
	-- case 2
	case when c.concept_name = 'No matching concept' then
	---- case 2a
	case when m3.source_concept_id IS NOT NULL then split_part(procedure_source_value,'.',1)  
	---- case 2b
	else 'NM'||cast(round(random()*1000000000) as text) end 
	--case 1
	else c.concept_code end as px,
	case when c.concept_name = 'No matching concept' then 
		case when m3.source_concept_id IS NOT NULL then m3.target_concept 
	else 'OT' end 
	else coalesce(m1.target_concept,'NI') end as px_type,
	split_part(procedure_source_value,'.',1) as raw_px,
	case when c2.vocabulary_id IS Null then 'Other' else c2.vocabulary_id end as raw_px_type
from
	omop.procedure_occurrence po
	join pcornet.encounter enc on cast(po.visit_occurrence_id as text)=enc.encounterid
	join rz.concept c on po.procedure_source_concept_id=c.concept_id
	-- get the vocabulary from procedure concept id - to populate the PX_TYPE field (case 1)
	left join cz.cz_omop_pcornet_concept_map m1 on c.vocabulary_id = m1.source_concept_id AND m1.source_concept_class='Procedure Code Type'
	-- get the vocabulary for the RAW_PX_TYPE field - for all cases. 
	left join rz.concept c2 on po.procedure_source_concept_id = c2.concept_id 
	-- get the vocabulary from the procedure source value to populate the PX_TYPE field (case 2a)
	left join cz.cz_omop_pcornet_concept_map m3 on c.vocabulary_id = m3.source_concept_id AND m3.source_concept_class='Procedure Code Type' 

-- observation --> vital 
-- Changes from previous version:
---- Change source table from observation to measurement
---- Populate vital_source, raw vital source, raw diastolic and raw systolic
---- Use fact_relationship to tie diastolic BP and systolic PB
insert into pcornet.vital(
            patid, encounterid, measure_date, measure_time, vital_source, 
            ht, wt, diastolic, systolic, original_bmi, bp_position, raw_vital_source, 
            raw_diastolic, raw_systolic, raw_bp_position)
 WITH
	ms as (select distinct person_id, visit_occurrence_id,observation_date  from omop.observation where observation_concept_id IN ('3023540','3013762','3034703','3019962','3013940','3012888','3018586','3035856','3009395','3004249','3038553')),
	ms_ht as (select distinct measurement_id, visit_occurrence_id, measurement_date, value_as_number  from omop.measurement where observation_concept_id = '3023540'),
	ms_wt as (select distinct measurement_id,visit_occurrence_id, measurement_date, value_as_number  from omop.measurement where observation_concept_id = '3013762'),
	ms_bmi as (select distinct measurement_id,visit_occurrence_id, measurement_date, value_as_number  from omop.measurement where observation_concept_id = '3038553'),
	ms_sys as (select distinct measurement_id, visit_occurrence_id, measurement_date, value_as_number, value_as_concept_id, observation_concept_id from omop.measurement where observation_concept_id in ('3018586','3035856','3009395','3004249')),
	ms_dia as (select distinct measurement_id, visit_occurrence_id, measurement_date, measurement_type_concept_id from omop.measurement where observation_concept_id in ('3034703','3019962','3013940','3012888')),
	ms_vs as (select distinct measurement_id, visit_occurrence_id, measurement_date, measurement_type_concept_id from omop.measurement where measurement_type_concept_id IN ('44814721','38000276'))
SELECT 
	cast(ob.person_id as text) as patid,
	cast(ob.visit_occurrence_id as text) as encounterid,
	cast(date_part('year', ob.observation_date) as text)||'-'||lpad(cast(date_part('month', ob.observation_date) as text),2,'0')||'-'||lpad(cast(date_part
	('day', ob.observation_date) as text),2,'0') as measure_date,
	lpad(cast(date_part('hour', ob.observation_date) as text),2,'0')||':'||lpad(cast(date_part('minute', ob.observation_date) as text),2,'0') as measure_time,
	ms_vs as vital_source,
    (ob_ht.value_as_number*0.393701) as ht, -- cm to inch conversion
    (ob_wt.value_as_number*2.20462) as wt, -- kg to pound conversion
	ob_dia.value_as_number as diastolic,
	ob_sys.value_as_number as systolic,
	ob_bmi.value_as_number as original_bmi,
	coalesce(m.target_concept,'OT') as bp_position,
	ms_vs.measurement_source_value as raw_vital_source,
	ms_dia.measurement_source_value as raw_diastolic,
	ms_sys.measurement_source_value as raw_systolic,
	null as raw_bp_position
FROM 
	ob 
	left join ms_ht on ms.visit_occurrence_id = ms_ht.visit_occurrence_id 
		and ob.observation_date = ms_ht.observation_date 
	left join ms_wt on ms.visit_occurrence_id = ms_wt.visit_occurrence_id 
		and ob.observation_date = ms_wt.observation_date 
	left join ms_sys on ms.visit_occurrence_id = ms_sys.visit_occurrence_id 
		and ob.observation_date = ms_sys.observation_date
	left join fact_relationship fr1 on fr1.fact_id_1 = ms_sys.measurement_id AND fr1.domain_concept_id_1=21 AND fr1.domain_concept_id_2=21
	left join ms_dia on ms.visit_occurrence_id = ms_dia.visit_occurrence_id 
		and ms_dia.measurement_id = fr1.fact_id_2
	left join ms_bmi on ms.visit_occurrence_id = ms_bmi.visit_occurrence_id 
		and ms.observation_date = ms_bmi.observation_date 
	left join cz.cz_omop_pcornet_concept_map m on ms_sys.observation_concept_id = m.source_concept_id AND m.source_concept_class='BP Position'
	where coalesce(ms_ht.value_as_number, ms_wt.value_as_number, ms_dia.value_as_number, ms_sys.value_as_number, ms_bmi.value_as_number) is not null;

