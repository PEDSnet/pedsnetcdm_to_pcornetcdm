--- extract 

create temporary table 
dis_disposition as (select distinct person_id,visit_occurrence_id,min(value_as_concept_id) as value_as_concept_id 
		from dcc_pedsnet.observation 
			where observation_concept_id = 44813951
			group by person_id,visit_occurrence_id); 
			
			
create temporary table 
drg_value as (select distinct person_id,visit_occurrence_id, min(value_as_string) as value_as_string as drg, 
		case when value_as_concept_id = 0 then 'OT' 
			else case when observation_date>='2007-10-01' then '02' else '01' end 
		end as drg_type
		from dcc_pedsnet.observation
		where observation_concept_id = 3040464 
			and 
			(	-- MS-DRG
				(observation_date >='2007-10-01'
				and value_as_string in 
				(select concept_code from vocabulary.concept where invalid_reason is null and concept_class_id = 'MS-DRG' and vocabulary_id='DRG') 
				)
				OR 
				--- OLD system 
				(observation_date <'2007-10-01'
				and value_as_string in 
				(select concept_code from vocabulary.concept where invalid_reason is null and concept_class_id = 'DRG' and vocabulary_id='DRG'
				 and invalid_date = '2007-09-30' and invalid_reason = 'D') 
				)
			)
			group by person_id,visit_occurrence_id
		); 
		
								
create temporary table encounter_extract 
as 
	select person_id, visit_occurrence_id, visit_start_date, visit_start_datetime
	, visit_end_time, visit_end_datetime, providerid, zip,
	visit_concept_id,  care_site_id, 
	dis_disposition.value_as_concept_id_ddisp,
	discharge_to_concept_id, admitting_source_concept_id,
    drg_value.drg as drg, 
    drg_value.drg_type as drg_type, 
	visit_source_value, discharge_to_source_value, 
	admitting_source_value, site
from 
	dcc_pedsnet.visit_occurrence v
	left join dcc_pedsnet.care_site c on v.care_site_id = c.care_site_id
	left join dcc_pedsnet.location l on c.location_id = l.location_id
	left join dis_disposition on v.visit_occurrence_id = dis_disposition.visit_occurrence_id 
	left join drg_value on v.visit_occurrence_id = drg_value.visit_occurrence_id 
	
	

--- transform valueset mapping 
	
create temporary table encounter_transform_valueset 
as
 select distinct 
	visit_occurrence_id,
	coalesce(m1.target_concept,'OT') as enc_type,
    coalesce(m2.target_concept,'NI')  as discharge_disposition,
	coalesce(m3a.target_concept,'NI') as discharge_status,
	coalesce(m4a.target_concept,'NI') as admitting_source
from 
	encounter_transform_valueset 
	join dcc_3dot1_pcornet.pedsnet_pcornet_valueset_map m1 
		on cast(visit_concept_id as text)= m1.source_concept_id and m1.source_concept_class='Encounter type'
	left join dcc_3dot1_pcornet.pedsnet_pcornet_valueset_map m2 on case when value_as_concept_id_ddisp is null AND m2.value_as_concept_id is null then true else 
				cast(value_as_concept_id_ddisp as text) = m2.value_as_concept_id end and m2.source_concept_class='Discharge disposition'
	left join dcc_3dot1_pcornet.pedsnet_pcornet_valueset_map m4a on admitting_source_concept_id = m4a.source_concept_id::integer 
			and m4a.source_concept_class='Admitting source'            
	left join dcc_3dot1_pcornet.pedsnet_pcornet_valueset_map m3a on cast(discharge_to_concept_id as text) = m3a.source_concept_id 
			and m3a.source_concept_class='Discharge status'


--- transform datashape
create temporary table encounter_transform_datashape
as 
 select distinct 
	cast(person_id as text) as patid,
	cast(visit_occurrence_id as text) as encounterid ,
	cast(cast(date_part('year', visit_start_date) as text)||'-'||lpad(cast(date_part('month', visit_start_date) as text),2,'0')||'-'||lpad(cast(date_part('day', visit_start_date) as text),2,'0') 
	as date) as admit_date,
    date_part('hour',visit_start_datetime)||':'||date_part('minute',visit_start_datetime) as admit_time,
	cast(cast(date_part('year', visit_end_date) as text)||'-'||lpad(cast(date_part('month', visit_end_date) as text),2,'0')||'-'||lpad(cast(date_part('day', visit_end_date) as text),2,'0')
	 as date) as discharge_date,
	date_part('hour',visit_end_datetime)||':'||date_part('minute',visit_end_datetime) as discharge_time,
	provider_id as providerid,
	left(zip,3) as facility_location,	
    care_site_id as facilityid,
    drg, 
	coalesce(drg_type,'NI'),
	visit_source_value as raw_enc_type,
	discharge_to_source_value as raw_discharge_disposition, 
	discharge_to_source_value as raw_discharge_status,
	null as raw_drg_type, -- since it is not discretely captured in the EHRs
	admitting_source_value as raw_admitting_source,
	site as site
from 
	encounter_extract; 
	


--- loading 
insert into dcc_3dot1_pcornet.encounter (
            patid, encounterid, admit_date, admit_time, discharge_date, discharge_time, 
            providerid, facility_location, enc_type, facilityid, discharge_disposition, 
            discharge_status, drg, drg_type, admitting_source, raw_enc_type, 
            raw_discharge_disposition, raw_discharge_status, raw_drg_type, 
            raw_admitting_source,site)
 select distinct 
	patid, 	encounterid , admit_date,
   	admit_time, discharge_date, discharge_time,
	providerid,facility_location,	enc_type,
    facilityid, discharge_disposition,discharge_status,
    drg, 	drg_type, admitting_source,
	raw_enc_type,
	raw_discharge_disposition, 
	raw_discharge_status,
	raw_drg_type, 
	raw_admitting_source,
	site
from 
	encounter_extract a, encounter_transform_valueset b, encounter_transform_datashape c
	where a.visit_occurrence_id = b.visit_occurrence_id 
	 and cast(a.visit_occurrence_id as text) = encounterid ,
