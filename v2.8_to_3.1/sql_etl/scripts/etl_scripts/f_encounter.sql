begin;

create table SITE_pcornet.dis_disposition 
as 
select distinct person_id,visit_occurrence_id,min(value_as_concept_id) as value_as_concept_id
from SITE_pedsnet.observation 
where observation_concept_id = 44813951
group by person_id,visit_occurrence_id); 
commit;

begin;

create table SITE_pcornet.drg_value as 
select distinct person_id,visit_occurrence_id, min(value_as_string) as value_as_string
from SITE_pedsnet.observation
where observation_concept_id = 3040464 and observation_date >'2007-10-01'
and value_as_string in (select concept_code from vocabulary.concept where invalid_reason is null and concept_class_id = 'MS-DRG' and vocabulary_id='DRG' ) 
group by person_id,visit_occurrence_id; 
commit;

begin;
create table SITE_pcornet.encounter_extract
as 
	select v.person_id, v.visit_occurrence_id, visit_start_date, visit_start_datetime
	, visit_end_date, visit_end_datetime, provider_id, zip,
	visit_concept_id,  v.care_site_id, 
	dis_disposition.value_as_concept_id value_as_concept_id_ddisp,
	discharge_to_concept_id, admitting_source_concept_id,
    drg_value.value_as_string as value_as_string_drg, 
	visit_source_value, discharge_to_source_value, 
	admitting_source_value, v.site
from 
	SITE_pedsnet.visit_occurrence v
	left join SITE_pedsnet.care_site c on v.care_site_id = c.care_site_id
	left join SITE_pedsnet.location l on c.location_id = l.location_id
	left join SITE_pcornet.dis_disposition on v.visit_occurrence_id = dis_disposition.visit_occurrence_id
	left join SITE_pcornet.drg_value on v.visit_occurrence_id = drg_value.visit_occurrence_id
	WHERE 
	v.person_id in (select person_id from SITE_pcornet.person_visit_start2001) and
    v.visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001);
commit;


begin;
--- transform datashape
create table SITE_pcornet.encounter_transform
as 
 select 
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
    value_as_string_drg as drg, -- -records having multiple DRGs
	case when visit_start_date<'2007-10-01' then '01' else '02' end as drg_type,
	visit_source_value as raw_enc_type,
	discharge_to_source_value as raw_discharge_disposition, 
	discharge_to_source_value as raw_discharge_status,
	null as raw_drg_type, -- since it is not discretely captured in the EHRs
	admitting_source_value as raw_admitting_source,
	coalesce(m1.target_concept,'OT') as enc_type,
    coalesce(m2.target_concept,'NI')  as discharge_disposition,
	coalesce(m3a.target_concept,'NI') as discharge_status,
	coalesce(m4a.target_concept,'NI') as admitting_source,
	site as site
from 
	SITE_pcornet.encounter_extract
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m1 
		on cast(visit_concept_id as text)= m1.source_concept_id and m1.source_concept_class='Encounter type'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m2 on case when value_as_concept_id_ddisp is null AND m2.value_as_concept_id is null then true else 
				cast(value_as_concept_id_ddisp as text) = m2.value_as_concept_id end and m2.source_concept_class='Discharge disposition'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m4a on admitting_source_concept_id = m4a.source_concept_id::integer 
			and m4a.source_concept_class='Admitting source'            
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m3a on cast(discharge_to_concept_id as text) = m3a.source_concept_id 
			and m3a.source_concept_class='Discharge status'; 
; 
	
commit;

begin;
--- loading 
insert into SITE_pcornet.encounter (
            patid, encounterid, admit_date, admit_time, discharge_date, discharge_time, 
            providerid, facility_location, enc_type, facilityid, discharge_disposition, 
            discharge_status, drg, drg_type, admitting_source, raw_enc_type, 
            raw_discharge_disposition, raw_discharge_status, 
            --raw_drg_type, 
            raw_admitting_source,site)
 select 
	patid, 	encounterid , admit_date,
   	admit_time, discharge_date, discharge_time,
	providerid,facility_location,	enc_type,
    facilityid, discharge_disposition,discharge_status,
    drg, 	drg_type, admitting_source,
	raw_enc_type,
	raw_discharge_disposition, 
	raw_discharge_status,
	--raw_drg_type, 
	raw_admitting_source,
	site
from 
	SITE_pcornet.encounter_transform;
	 
commit;
