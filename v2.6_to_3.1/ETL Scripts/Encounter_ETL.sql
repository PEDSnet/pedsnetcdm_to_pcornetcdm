
-- Visit occurrence -> encounter
insert into dcc_3dot1_pcornet.encounter (
            patid, encounterid, admit_date, admit_time, discharge_date, discharge_time, 
            providerid, facility_location, enc_type, facilityid, discharge_disposition, 
            discharge_status, drg, drg_type, admitting_source, raw_enc_type, 
            raw_discharge_disposition, raw_discharge_status, raw_drg_type, 
            raw_admitting_source,site)
WITH  o1 as (select distinct person_id,visit_occurrence_id,value_as_concept_id, observation_source_value from dcc_pedsnet.observation where observation_concept_id = 44813951) --- discharge disposition in PCORnet
     ,o2 as (select distinct person_id,visit_occurrence_id, min(value_as_string) as value_as_string
		from dcc_pedsnet.observation
		where observation_concept_id = 3040464 and observation_date >'2007-10-01'
			and value_as_string in (select concept_code from vocabulary.concept where invalid_reason is null and concept_class_id = 'MS-DRG' and vocabulary_id='DRG' ) 
			group by person_id,visit_occurrence_id
		)
     ,o3 as (select  person_id,visit_occurrence_id, min(value_as_concept_id) as value_as_concept_id
     			--,observation_source_value 
     			from dcc_pedsnet.observation where observation_concept_id = 4137274
     			group by person_id,visit_occurrence_id -- since Colorado has multiple discharge status 
     			) -- discharge status in PCORnet
     ,o4 as (select distinct value_as_concept_id, visit_occurrence_id, person_id,observation_source_value from dcc_pedsnet.observation where observation_concept_id = 4145666) --- admitting source in PCORnet
select distinct 
	cast(v.person_id as text) as pat_id,
	cast(v.visit_occurrence_id as text) as encounterid ,
	cast(cast(date_part('year', visit_start_date) as text)||'-'||lpad(cast(date_part('month', visit_start_date) as text),2,'0')||'-'||lpad(cast(date_part('day', visit_start_date) as text),2,'0') 
	as date) as admit_date,
    date_part('hour',visit_start_datetime)||':'||date_part('minute',visit_start_datetime) as admit_time,
	cast(cast(date_part('year', visit_end_date) as text)||'-'||lpad(cast(date_part('month', visit_end_date) as text),2,'0')||'-'||lpad(cast(date_part('day', visit_end_date) as text),2,'0')
	 as date) as discharge_date,
	date_part('hour',visit_end_datetime)||':'||date_part('minute',visit_end_datetime) as discharge_time,
	v.provider_id as providerid,
	left(l.zip,3) as facility_location,	
    coalesce(m1.target_concept,'OT') as enc_type,
    v.care_site_id as facilityid,
    coalesce(m2.target_concept)  as discharge_disposition,
	coalesce(m3a.target_concept,'NI') as discharge_status,
    o2.value_as_string as drg, -- -records having multiple DRGs
	case when visit_start_date<'2007-10-01' then '01' else '02' end as drg_type,
	coalesce(m4.target_concept,coalesce(m4a.target_concept,'NI'))  as admitting_source,
	v.visit_source_value as raw_enc_type,
	v.discharge_to_source_value as raw_discharge_disposition, 
	v.discharge_to_source_value as raw_discharge_status,
	null as raw_drg_type, -- since it is not discretely captured in the EHRs
	v.admitting_source_value as raw_admitting_source,
	v.site as site
from 
	dcc_pedsnet.visit_occurrence v
	left join dcc_pedsnet.care_site c on v.care_site_id = c.care_site_id
	left join dcc_pedsnet.location l on c.location_id = l.location_id
	left join o1 on v.visit_occurrence_id = o1.visit_occurrence_id 
	left join o2 on v.visit_occurrence_id = o2.visit_occurrence_id 
	left join o3 on v.visit_occurrence_id = o3.visit_occurrence_id 
	left join o4 on v.visit_occurrence_id = o4.visit_occurrence_id 
	 join dcc_3dot1_pcornet.pedsnet_pcornet_valueset_map m1 
		on cast(v.visit_concept_id as text)= m1.source_concept_id and m1.source_concept_class='Encounter type'
	left join dcc_3dot1_pcornet.pedsnet_pcornet_valueset_map m2 on case when o1.value_as_concept_id is null AND m2.value_as_concept_id is null then true else 
				o1.value_as_concept_id = m2.value_as_concept_id end and m2.source_concept_class='Discharge disposition'
	left join dcc_3dot1_pcornet.pedsnet_pcornet_valueset_map m4a on v.admitting_source_concept_id = m4a.source_concept_id
			and m4a.source_concept_class='Admitting source'
	left join dcc_3dot1_pcornet.pedsnet_pcornet_valueset_map m3a on v.discharge_to_concept_id = m3a.source_concept_id
			and m3a.source_concept_class='Discharge status'
