begin;

INSERT INTO SITE_pcornet.immunization(immunizationid, patid, encounterid, proceduresid, vx_providerid,
vx_record_date, vx_admin_date, vx_code_type, vx_code, vx_status, vx_status_reason, vx_source, vx_dose,
vx_dose_unit, vx_route, vx_body_site, vx_manufacturer, vx_lot_num, vx_exp_date, raw_vx_name,
raw_vx_code, raw_vx_code_type, raw_vx_dose, raw_vx_dose_unit, raw_vx_route, raw_vx_body_site,
raw_vx_status, raw_vx_status_reason, site)
select distinct on (immunization_id)imm.immunization_id::text as immunizationid,
        imm.person_id::text as patid,
		imm.visit_occurrence_id::text as encounterid,
		imm.procedure_occurrence_id::text as proceduresid,
		imm.provider_id::text as vx_providerid,
		imm.imm_recorded_date  as vx_record_date,
		imm.immunization_date as vx_admin_date,
		coalesce(m1.target_concept, 'OT') as vx_code_type,
		case when imm.immunization_concept_id = 0 then trim(split_part(imm.immunization_source_value,'|',2))
				 else c.concept_code end  as vx_code,
		'CP' as vx_status,
		null as vx_status_reason,
		coalesce(c1.concept_code,'OT') as vx_source, 
		case when length(imm.immunization_dose) <= 8 then nullif(regexp_replace(imm.immunization_dose, '[^0-9.]*','','g'), '')::numeric 
			 else left(nullif(regexp_replace(imm.immunization_dose, '[^0-9.]*','','g'), ''),8)::numeric end as vx_dose,
		coalesce(m2.target_concept, 'OT') as vx_dose_unit,
		coalesce(m3.target_concept, 'OT') as vx_route,
		coalesce(bdy_site.target_concept,'NI') as vx_body_site, --bdy_site_2.target_concept, bdy_site_3.target_concept,
		case when imm.imm_manufacturer is null or imm.imm_manufacturer = '' then 'NI'
			else coalesce(manf_3.target_concept,'OTH') end as vx_manufacturer, -- coalesce(manf1.target_concept,manf2.target_concept,'OTH')  
		imm.imm_lot_num as vx_lot_num,
		imm.imm_exp_date as vx_exp_date,
		c.concept_name as raw_vx_name,
        c.concept_code as raw_vx_code,
		c.vocabulary_id as raw_vx_code_type,
		imm.immunization_dose as raw_vx_dose,
		imm.imm_dose_unit_source_value as raw_vx_dose_unit,
		imm.imm_route_source_value as raw_vx_route,
		imm.imm_body_site_source_value as raw_vx_body_site,
        'CP' as raw_vx_status,
		null as raw_vx_status_reason,
		'SITE' as site
from SITE_pedsnet.immunization imm																																				 
left join vocabulary.concept c on c.concept_id = imm.immunization_concept_id
left join vocabulary.concept c1 on c1.concept_id = imm.immunization_type_concept_id and c1.domain_id = 'Immunization Type'	and c1.vocabulary_id = 'PEDSnet'																 																	   
left join pcornet_maps.pedsnet_pcornet_valueset_map  m1 on m1.source_concept_id = c.vocabulary_id and m1.source_concept_class = 'immunization_type'
left join pcornet_maps.pedsnet_pcornet_valueset_map m2 on cast(imm.imm_dose_unit_concept_id as text) = m2.source_concept_id
			and m2.source_concept_class='Dose unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map m3 on cast(imm.imm_route_concept_id as text) = m3.source_concept_id
			and m3.source_concept_class='Route'
left join pcornet_maps.pedsnet_pcornet_valueset_map bdy_site on case when imm.imm_body_site_concept_id is not null 
then imm.imm_body_site_concept_id::text = bdy_site.source_concept_id and bdy_site.source_concept_class = 'imm_body_site' and bdy_site.source_concept_id is not null
else lower(bdy_site.pcornet_name) ilike '%'||lower(trim(split_part(imm_body_site_source_value,'|',1)))||'%' and bdy_site.source_concept_class = 'imm_body_site_source' and bdy_site.source_concept_id is null end
left join pcornet_maps.pedsnet_pcornet_valueset_map manf_3 on imm.imm_manufacturer ~* manf_3.source_concept_id and manf_3.source_concept_class = 'vx_manufacturer'
where
	imm.person_id IN (select person_id from SITE_pcornet.person_visit_start2001);
commit;

begin;
delete from SITE_pcornet.immunization 
where encounterid IS NOT null and
	   encounterid::int NOT IN (select visit_id from SITE_pcornet.person_visit_start2001);
commit;

begin;
update SITE_pcornet.immunization
set vx_code = coalesce(c.concept_code,'')
from SITE_pcornet.immunization i
left join SITE_pedsnet.immunization im on im.immunization_id = i.immunizationid::int
left join vocabulary.concept c on c.concept_name @@ im.immunization_source_value
                                and concept_class_id = 'CVX'
where i.vx_code = ''
and SITE_pcornet.immunization.immunizationid = i.immunizationid;
commit;