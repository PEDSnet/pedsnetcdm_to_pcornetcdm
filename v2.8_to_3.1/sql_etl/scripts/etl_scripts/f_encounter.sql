begin;

-- filtered observation table
create table if not exists SITE_pcornet.observation
as
select person_id, visit_occurrence_id, observation_id,
       observation_date, observation_datetime, observation_concept_id,
       case when observation_concept_id = 44813951 
            then min(o.value_as_concept_id)
            else min(o.value_as_concept_id)
       end as value_as_concept_id, 
       case when observation_concept_id = 3040464 and observation_date > '2007-10-01'
                 and o.value_as_string in (
			                                select concept_code
			                                from vocabulary.concept
			                                where invalid_reason is null and
			                                      concept_class_id = 'MS-DRG' and
			                                      vocabulary_id='DRG'
			                             )
            then min(o.value_as_string)
            else min(o.value_as_string)
        end as value_as_string     
from SITE_pedsnet.observation o
where visit_occurrence_id is not null and
      person_id in (select person_id from SITE_pcornet.person_visit_start2001) and
      visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001)
group by person_id,visit_occurrence_id,observation_concept_id, observation_date, observation_id;

commit;


begin;

alter table SITE_pcornet.encounter  add column site character varying not null;

insert into stlouis_pcornet.encounter (
            patid, encounterid, admit_date, admit_time, discharge_date, discharge_time,
            providerid, facility_location, enc_type, facilityid, discharge_disposition,
            discharge_status, drg, drg_type, admitting_source, raw_enc_type,
            raw_discharge_disposition, raw_discharge_status, raw_drg_type,
            raw_admitting_source,site)
WITH
dis_disposition as (
                           select distinct on (visit_occurrence_id) visit_occurrence_id, person_id, count(value_as_concept_id), min (value_as_concept_id) as value_as_concept_id
		                   from stlouis_pedsnet.observation
			               where observation_concept_id = 44813951
    							 and visit_occurrence_id in (select visit_id from stlouis_pcornet.person_visit_start2001)
			               group by 1, 2
			        ),
drg_value as (
                select distinct person_id,visit_occurrence_id, min(value_as_string) as value_as_string
		        from stlouis_pedsnet.observation
		        where observation_concept_id = 3040464 and
		              observation_date >'2007-10-01' and
		              value_as_string in (
			                                select concept_code
			                                from vocabulary.concept
			                                where invalid_reason is null and
			                                      concept_class_id = 'MS-DRG' and
			                                      vocabulary_id='DRG'
			                             )
			    group by person_id,visit_occurrence_id
		     )
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
    coalesce(m2.target_concept,'NI')  as discharge_disposition,
	coalesce(m3a.target_concept,'NI') as discharge_status,
    drg_value.value_as_string as drg, -- -records having multiple DRGs
	case when visit_start_date<'2007-10-01'
	     then '01'
	     else '02'
	     end as drg_type,
	coalesce(m4a.target_concept,'NI') as admitting_source,
	v.visit_source_value as raw_enc_type,
	v.discharge_to_source_value as raw_discharge_disposition,
	v.discharge_to_source_value as raw_discharge_status,
	null as raw_drg_type,
	v.admitting_source_value as raw_admitting_source,
	v.site as site
from
	stlouis_pedsnet.visit_occurrence v
	left join stlouis_pedsnet.care_site c on v.care_site_id = c.care_site_id
	left join stlouis_pedsnet.location l on c.location_id = l.location_id
	left join dis_disposition on v.visit_occurrence_id = dis_disposition.visit_occurrence_id
	left join drg_value on v.visit_occurrence_id = drg_value.visit_occurrence_id
	join stlouis_pcornet.pedsnet_pcornet_valueset_map m1
		on cast(v.visit_concept_id as text)= m1.source_concept_id and m1.source_concept_class='Encounter type'
	left join stlouis_pcornet.pedsnet_pcornet_valueset_map m2 on case when dis_disposition.value_as_concept_id is null AND m2.value_as_concept_id is null
	                                                                     then true
	                                                                     else cast(dis_disposition.value_as_concept_id as text) = m2.value_as_concept_id
	                                                                     end
	                                                                     and m2.source_concept_class='Discharge disposition'
	left join stlouis_pcornet.pedsnet_pcornet_valueset_map m4a on v.admitting_source_concept_id = m4a.source_concept_id::integer
			and m4a.source_concept_class='Admitting source'
	left join stlouis_pcornet.pedsnet_pcornet_valueset_map m3a on cast(v.discharge_to_concept_id as text) = m3a.source_concept_id
			and m3a.source_concept_class='Discharge status'
    where
    v.person_id in (select person_id from stlouis_pcornet.person_visit_start2001);

commit;

