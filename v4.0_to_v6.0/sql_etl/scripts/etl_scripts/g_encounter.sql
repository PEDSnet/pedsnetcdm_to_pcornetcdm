begin;

create  table SITE_pcornet.dis_disposition 
as 
select distinct person_id, visit_occurrence_id,min(value_as_concept_id) as value_as_concept_id 
from SITE_pedsnet.observation 
where observation_concept_id = 44813951
group by person_id,visit_occurrence_id;

CREATE INDEX idx_disp_visid
    ON SITE_pcornet.dis_disposition USING btree
    (visit_occurrence_id)
    TABLESPACE pg_default;
			
			
create  table SITE_pcornet.drg_value 
as 
select distinct on (o.person_id)o.person_id, visit_occurrence_id,
       case when count(value_as_string)>1 and qualifier_concept_id = '4269228' then value_as_string
            else value_as_string
			end as value_as_string
from SITE_pedsnet.observation o
where observation_concept_id = 3040464 and
       observation_date >= '2007-10-01'::date and
	   value_as_string in ( select concept_code
						    from vocabulary.concept v
						    where invalid_reason is null and
	                               concept_class_id = 'MS-DRG' and
	                               vocabulary_id='DRG'
						   )
group by o.person_id, visit_occurrence_id, qualifier_concept_id, value_as_string
order by person_id asc;

CREATE INDEX idx_drg_visid
    ON SITE_pcornet.drg_value USING btree
    (visit_occurrence_id)
    TABLESPACE pg_default;


-- Link the visit payer infromation
create table SITE_pcornet.visit_payer as
select distinct on (visit_occurrence_id) visit_occurrence_id, visit_payer_id, 
	    case when visit_payer_type_concept_id = 31968 then TRUE
			  when visit_payer_type_concept_id = 31969 then FALSE
			  else null
			  end as primary_payer_flag,
	        plan_name, plan_type, plan_class, m5.target_concept as payer
from SITE_pedsnet.visit_payer
left join pcornet_maps.pedsnet_pcornet_valueset_map m5 on cast(plan_class||'-'||plan_type as text) = m5.source_concept_id 
			and m5.source_concept_class='Payer'
where visit_occurrence_id IN (select visit_id from SITE_pcornet.person_visit_start2001)
order by visit_occurrence_id, target_concept asc ; -- extracting the visits that have valid minimum payer which mapped to target_concept

CREATE INDEX idx_vispay_visid
    ON SITE_pcornet.visit_payer USING btree
    (visit_occurrence_id)
    TABLESPACE pg_default;

-- Extract Data
create  table SITE_pcornet.encounter_extract
as 
	select v.person_id, 
	v.visit_occurrence_id, 
	visit_start_date, 
	visit_start_datetime, 
	visit_end_date, 
	visit_end_datetime, 
	provider_id, 
	zip,
	visit_concept_id,  
	v.care_site_id, 
	place_of_service_concept_id, 
	specialty_concept_id, 
	case when dis_disposition.value_as_concept_id in (4161979,4216643) then dis_disposition.value_as_concept_id
	else case when v.discharge_to_concept_id in (4216643) then v.discharge_to_concept_id
	else 4161979 end end as value_as_concept_id_ddisp,
	discharge_to_concept_id, 
	admitted_from_concept_id,
    drg_value.value_as_string as value_as_string_drg, 
	visit_source_value, 
	discharge_to_source_value, 
	admitted_from_source_value,
	case when primary_payer_flag is true then plan_class||'-'||plan_type
	     else 'NI' end as raw_payer_type_primary,
	case when primary_payer_flag is false then plan_class||'-'||plan_type
	     else 'NI' end as raw_payer_type_secondary,
	case when primary_payer_flag is true then plan_name
	     else 'NI' end as raw_payer_name_primary,
	case when primary_payer_flag is false then plan_name
	     else 'NI' end as raw_payer_name_secondary,
	case when primary_payer_flag is true then visit_payer_id
	     else null end as raw_payer_id_primary,
	case when primary_payer_flag is false then visit_payer_id
	     else null end as raw_payer_id_secondary,
	case when primary_payer_flag is true then payer
	     else 'NI' end as payer_type_primary,
	case when primary_payer_flag is false then payer
	     else 'NI' end as payer_type_secondary,
	'SITE' as site
from SITE_pedsnet.visit_occurrence v
left join SITE_pedsnet.care_site c on v.care_site_id = c.care_site_id
left join SITE_pedsnet.location l on c.location_id = l.location_id
left join SITE_pcornet.dis_disposition on v.visit_occurrence_id = dis_disposition.visit_occurrence_id 
left join SITE_pcornet.drg_value on v.visit_occurrence_id = drg_value.visit_occurrence_id 
left join SITE_pcornet.visit_payer vp on v.visit_occurrence_id = vp.visit_occurrence_id 
WHERE  v.visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001);

--- transform datashape

create  table SITE_pcornet.encounter_transform 
as 
 select distinct
	cast(person_id as text) as patid,
	cast(encounter_extract.visit_occurrence_id as text) as encounterid ,
	cast(cast(date_part('year', visit_start_date) as text)||'-'||lpad(cast(date_part('month', visit_start_date) as text),2,'0')||'-'||lpad(cast(date_part('day', visit_start_date) as text),2,'0') 
	as date) as admit_date,
    date_part('hour',visit_start_datetime)||':'||date_part('minute',visit_start_datetime) as admit_time,
	cast(cast(date_part('year', visit_end_date) as text)||'-'||lpad(cast(date_part('month', visit_end_date) as text),2,'0')||'-'||lpad(cast(date_part('day', visit_end_date) as text),2,'0')
	 as date) as discharge_date,
	date_part('hour',visit_end_datetime)||':'||date_part('minute',visit_end_datetime) as discharge_time,
	provider_id as providerid,
	case when zip !~ '^[0-9]+$' then null else left(zip, 5) end as facility_location,
    care_site_id as facilityid,
    value_as_string_drg as drg, -- -records having multiple DRGs
	case when visit_start_date<'2007-10-01' then '01' else '02' end as drg_type,
	visit_source_value as raw_enc_type,
	discharge_to_source_value as raw_discharge_disposition, 
	discharge_to_source_value as raw_discharge_status,
	null as raw_drg_type, -- since it is not discretely captured in the EHRs
	admitted_from_source_value as raw_admitting_source,
	coalesce(m1.target_concept,'OT') as enc_type,
    coalesce(m2.target_concept,'A')  as discharge_disposition,
	coalesce(m3a.target_concept,'NI') as discharge_status,
	coalesce(m4a.target_concept,'NI') as admitting_source,
	payer_type_primary,
	payer_type_secondary,
	raw_payer_type_primary,
	raw_payer_type_secondary,
	raw_payer_id_primary,
	raw_payer_id_secondary,
	raw_payer_name_primary,
	raw_payer_name_secondary,
	 coalesce(  m6.target_concept,  m7.target_concept, 
           m8.target_concept, 'NI')
      as facility_type, 
      coalesce(  m6.source_concept_id,  m7.source_concept_id, 
           m8.source_concept_id, NULL) as raw_facility_type,
	site
from SITE_pcornet.encounter_extract
left join pcornet_maps.pedsnet_pcornet_valueset_map m1 on cast(visit_concept_id as text)= m1.source_concept_id 
                                                           and m1.source_concept_class='Encounter type'
left join pcornet_maps.pedsnet_pcornet_valueset_map m2 on case when value_as_concept_id_ddisp is null
                                                                    AND m2.value_as_concept_id is null then true
                                                               else cast(value_as_concept_id_ddisp as text) = m2.value_as_concept_id
                                                               end
															   and m2.source_concept_class='Discharge disposition'
left join pcornet_maps.pedsnet_pcornet_valueset_map m4a on cast(admitted_from_concept_id as text) = m4a.source_concept_id
			                                             and m4a.source_concept_class='Admitting source'            
left join pcornet_maps.pedsnet_pcornet_valueset_map m3a on cast(discharge_to_concept_id as text) = m3a.source_concept_id 
			                                             and m3a.source_concept_class='Discharge status'
left join pcornet_maps.pedsnet_pcornet_valueset_map m6 on cast(place_of_service_concept_id as text) = m6.source_concept_id
                                                        and m6.source_concept_class='Facility type'  and m6.source_concept_id is not null
left join pcornet_maps.pedsnet_pcornet_valueset_map m7 on cast(visit_concept_id as text) = m7.source_concept_id
                                                        and cast(specialty_concept_id as text) = m7.value_as_concept_id
                                                        and m7.source_concept_class='Facility type' and m7.value_as_concept_id is not null      
left join pcornet_maps.pedsnet_pcornet_valueset_map m8 on cast(visit_concept_id as text) = m8.source_concept_id
                                                        and m8.source_concept_class='Facility type'  
			                                            and m8.value_as_concept_id is null ;

--- loading 
insert into SITE_pcornet.encounter (admit_date, admit_time, admitting_source, discharge_date, discharge_disposition, 
	discharge_status, discharge_time, drg, drg_type, enc_type, encounterid, facility_location, 
	facility_type, facilityid, patid, payer_type_primary, payer_type_secondary, providerid, 
	raw_admitting_source, raw_discharge_disposition, raw_discharge_status, raw_drg_type, 
	raw_enc_type, raw_facility_type, raw_payer_id_primary, raw_payer_id_secondary, 
	raw_payer_name_primary, raw_payer_name_secondary, raw_payer_type_primary, raw_payer_type_secondary, 
	raw_siteid, site)
 select 
	admit_date, admit_time, admitting_source, discharge_date, discharge_disposition, 
	discharge_status, discharge_time, drg, drg_type, enc_type, encounterid, facility_location, 
	facility_type, facilityid, patid, payer_type_primary, payer_type_secondary, providerid, 
	raw_admitting_source, raw_discharge_disposition, raw_discharge_status, raw_drg_type, 
	raw_enc_type, raw_facility_type, raw_payer_id_primary, raw_payer_id_secondary, 
	raw_payer_name_primary, raw_payer_name_secondary, raw_payer_type_primary, raw_payer_type_secondary, 
	site as raw_siteid, site
from 
	SITE_pcornet.encounter_transform; 
	 
commit;

