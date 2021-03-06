=======

-- Person 
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
	v.place_of_service_concept_id as raw_enc_type,
	case when o1.person_id is null then null else cast(o1.value_as_concept_id as text) end as raw_discharge_disposition,
	min(case when o3.person_id is null then null else cast(o3.value_as_concept_id as text) end) as raw_discharge_status,
	null as raw_drg_type,
	case when o4.person_id is null then null else cast(o4.value_as_concept_id as text) end as raw_admitting_source
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
	case when split_part(condition_source_value,'|||',2) ='6' 
		then split_part(condition_source_value,'|||',1)
	-- case 2: when source value doesnt exist... check if concept id = non-zero and source vocab is one of the five, then include concept id (SNOMED CT code) else random number
	else case when condition_concept_id>0  
		then (select distinct concept_code from concept c where c.concept_id = co.condition_concept_id)
	else 'NM'||cast(round(random()*10000000000000) as text) end end as dx,
	case when  split_part(condition_source_value,'|||',2) ='6' then '09'
		else case when condition_concept_id>0  then 'SM' else 'OT' end
	end as dx_type,
	null as dx_source,
	null as pdx,
	split_part(condition_source_value,'|||',1)  as raw_dx,
	m1.target_concept as raw_dx_type,
	null as raw_dx_source,
	null as raw_pdx
from
	omop.condition_occurrence co
	join pcornet.encounter enc on cast(co.visit_occurrence_id as text)=enc.encounterid
	-- find source coding system name for raw_dx_type
	left join cz.cz_omop_pcornet_concept_map m1 on split_part(condition_source_value,'|||',2) = cast(m1.source_concept_id as text) AND m1.source_concept_class ='Source Coding System'


-- procedure_occurrence -> Procedure
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
	case when split_part(procedure_source_value,'|||',2) = cast(m3.source_concept_id as text) then split_part(split_part(procedure_source_value,'|||',1),'.',1)  
	---- case 2b
	else 'NM'||cast(round(random()*1000000000) as text) end 
	--case 1
	else c.concept_code end as px,
	case when c.concept_name = 'No matching concept' then 
	case when split_part(procedure_source_value,'|||',2) = cast(m3.source_concept_id as text) then m3.target_concept 
	else 'OT' end 
	else coalesce(m1.target_concept,'NI') end as px_type,
	split_part(split_part(procedure_source_value,'|||',1),'.',1) as raw_px,
	case when m2.target_concept IS Null then 'Other' else m2.target_concept end as raw_px_type
from
	omop.procedure_occurrence po
	join pcornet.encounter enc on cast(po.visit_occurrence_id as text)=enc.encounterid
	join rz.concept c on po.procedure_concept_id=c.concept_id
	-- get the vocabulary from procedure concept id - to populate the PX_TYPE field (case 1)
	left join cz.cz_omop_pcornet_concept_map m1 on cast(c.vocabulary_id as text) = cast(m1.source_concept_id as text) AND m1.source_concept_class='Procedure Code Type'
	-- get the vocabulary for the RAW_PX_TYPE field - for all cases. 
	left join cz.cz_omop_pcornet_concept_map m2 on case when split_part(procedure_source_value,'|||',2) is null AND m2.source_concept_id is null then true else split_part(procedure_source_value,'|||',2) = cast(m2.source_concept_id as text) end AND m2.source_concept_class ='Source Coding System'
	-- get the vocabulary from the procedure source value to populate the PX_TYPE field (case 2a)
	left join cz.cz_omop_pcornet_concept_map m3 on split_part(procedure_source_value,'|||',2) = cast(m3.source_concept_id as text) AND m3.source_concept_class='Procedure Code Type' 

-- observation --> vital 
insert into pcornet.vital(
            patid, encounterid, measure_date, measure_time, vital_source, 
            ht, wt, diastolic, systolic, original_bmi, bp_position, raw_vital_source, 
            raw_diastolic, raw_systolic, raw_bp_position)
 WITH
	ob as (select distinct person_id, visit_occurrence_id,observation_date  from omop.observation where observation_concept_id IN ('3023540','3013762','3034703','3019962','3013940','3012888','3018586','3035856','3009395','3004249','3038553')),
	ob_ht as (select distinct visit_occurrence_id, observation_date, value_as_number  from omop.observation where observation_concept_id = '3023540'),
	ob_wt as (select distinct visit_occurrence_id, observation_date, value_as_number  from omop.observation where observation_concept_id = '3013762'),
	ob_bmi as (select distinct visit_occurrence_id, observation_date, value_as_number  from omop.observation where observation_concept_id = '3038553'),
	ob_sys as (select distinct visit_occurrence_id, observation_date, value_as_number, value_as_concept_id, observation_concept_id from omop.observation where observation_concept_id in ('3018586','3035856','3009395','3004249')),
	ob_dia as (select distinct visit_occurrence_id, observation_date, value_as_number, value_as_concept_id from omop.observation where observation_concept_id in ('3034703','3019962','3013940','3012888'))
SELECT
	cast(ob.person_id as text) as patid,
	cast(ob.visit_occurrence_id as text) as encounterid,
	cast(date_part('year', ob.observation_date) as text)||'-'||lpad(cast(date_part('month', ob.observation_date) as text),2,'0')||'-'||lpad(cast(date_part
	('day', ob.observation_date) as text),2,'0') as measure_date,
	lpad(cast(date_part('hour', ob.observation_date) as text),2,'0')||':'||lpad(cast(date_part('minute', ob.observation_date) as text),2,'0') as measure_time,
	null as vital_source,
    (ob_ht.value_as_number*0.393701) as ht, -- cm to inch conversion
    (ob_wt.value_as_number*2.20462) as wt, -- kg to pound conversion
	ob_dia.value_as_number as diastolic,
	ob_sys.value_as_number as systolic,
	ob_bmi.value_as_number as original_bmi,
	coalesce(m.target_concept,'OT') as bp_position,
	null as raw_vital_source,
	null as raw_diastolic,
	null as raw_systolic,
	null as raw_bp_position
FROM 
	ob 
	left join ob_ht on ob.visit_occurrence_id = ob_ht.visit_occurrence_id 
		and ob.observation_date = ob_ht.observation_date 
	left join ob_wt on ob.visit_occurrence_id = ob_wt.visit_occurrence_id 
		and ob.observation_date = ob_wt.observation_date 
	left join ob_sys on ob.visit_occurrence_id = ob_sys.visit_occurrence_id 
		and ob.observation_date = ob_sys.observation_date 
	left join ob_dia on ob.visit_occurrence_id = ob_dia.visit_occurrence_id 
		and ob_sys.value_as_concept_id = ob_dia.value_as_concept_id
	left join ob_bmi on ob.visit_occurrence_id = ob_bmi.visit_occurrence_id 
		and ob.observation_date = ob_bmi.observation_date 
	left join cz.cz_omop_pcornet_concept_map m on ob_sys.observation_concept_id = m.source_concept_id AND m.source_concept_class='BP Position'
	where coalesce(ob_ht.value_as_number, ob_wt.value_as_number, ob_dia.value_as_number, ob_sys.value_as_number, ob_bmi.value_as_number) is not null;
