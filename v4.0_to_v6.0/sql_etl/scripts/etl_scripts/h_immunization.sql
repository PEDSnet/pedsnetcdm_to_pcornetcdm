begin;
create table SITE_pcornet.imm_code as
select imm.immunization_id::text as immunizationid,
        imm.person_id::text as patid,
		imm.visit_occurrence_id::text as encounterid,
		imm.procedure_occurrence_id::text as proceduresid,
		imm.provider_id::text as vx_providerid,
		imm.imm_recorded_date  as vx_record_date,
		imm.immunization_date as vx_admin_date,
		coalesce(pcor_imm_type.target_concept, 'OT') as vx_code_type,
		case when imm.immunization_concept_id = 0 then trim(split_part(imm.immunization_source_value,'|',2))
				 else code.concept_code end  as vx_code,
		'CP' as vx_status,
		null as vx_status_reason,
		coalesce(imm_type.concept_code,'OT') as vx_source, 
		imm.immunization_dose, imm.imm_dose_unit_concept_id,
		imm.imm_route_concept_id,imm.imm_body_site_concept_id, imm.imm_body_site_source_value, imm.imm_manufacturer,		
		imm.imm_lot_num as vx_lot_num,
		imm.imm_exp_date as vx_exp_date,
		code.concept_name as raw_vx_name,
        code.concept_code as raw_vx_code,
		code.vocabulary_id as raw_vx_code_type,
		imm.imm_dose_unit_source_value,
		imm.imm_route_source_value,
        'CP' as raw_vx_status,
		null as raw_vx_status_reason,
		'SITE' as site
from SITE_pedsnet.immunization imm																																				 
left join vocabulary.concept code on code.concept_id = imm.immunization_concept_id
left join vocabulary.concept imm_type on imm_type.concept_id = imm.immunization_type_concept_id and imm_type.domain_id = 'Immunization Type' and imm_type.vocabulary_id = 'PEDSnet'																 																	   
left join pcornet_maps.pedsnet_pcornet_valueset_map pcor_imm_type on pcor_imm_type.source_concept_id = code.vocabulary_id and pcor_imm_type.source_concept_class = 'immunization_type'
where imm.person_id IN (select person_id from SITE_pcornet.person_visit_start2001);
commit;

begin;
create table SITE_pcornet.imm_dose as
select immunizationid,patid,encounterid,proceduresid,vx_providerid,vx_record_date,vx_admin_date,vx_code_type,
		vx_code,vx_status,vx_status_reason,vx_source, 
		case when length(imm.immunization_dose) <= 8 then nullif(regexp_replace(imm.immunization_dose, '[^0-9.]*','','g'), '')::numeric 
			 else left(nullif(regexp_replace(imm.immunization_dose, '[^0-9.]*','','g'), ''),8)::numeric end as vx_dose,
		coalesce(dose_unit.target_concept, 'OT') as vx_dose_unit,
		imm.imm_route_concept_id,imm.imm_body_site_concept_id, imm.imm_body_site_source_value, imm.imm_manufacturer,		
        vx_lot_num,vx_exp_date,raw_vx_name,raw_vx_code,raw_vx_code_type,imm.immunization_dose as raw_vx_dose,
		imm.imm_dose_unit_source_value as raw_vx_dose_unit,
		imm.imm_route_source_value,raw_vx_status,raw_vx_status_reason,site
from SITE_pcornet.imm_code imm																																				 
left join pcornet_maps.pedsnet_pcornet_valueset_map dose_unit on cast(imm.imm_dose_unit_concept_id as text) = dose_unit.source_concept_id
			and dose_unit.source_concept_class='Dose unit';
commit;

begin;
drop table SITE_pcornet.imm_code;
commit;

begin;
create table SITE_pcornet.imm_route as
select immunizationid,patid,encounterid,proceduresid,vx_providerid,vx_record_date,vx_admin_date,vx_code_type,
		vx_code,vx_status,vx_status_reason,vx_source, vx_dose, vx_dose_unit,
		coalesce(m3.target_concept, 'OT') as vx_route,
		imm.imm_body_site_concept_id, imm.imm_body_site_source_value, imm.imm_manufacturer,	vx_lot_num,
		vx_exp_date,raw_vx_name,raw_vx_code,raw_vx_code_type,raw_vx_dose,raw_vx_dose_unit,
		imm.imm_route_source_value as raw_vx_route,
		raw_vx_status,raw_vx_status_reason,site
from SITE_pcornet.imm_dose imm																																				 
left join pcornet_maps.pedsnet_pcornet_valueset_map m3 on cast(imm.imm_route_concept_id as text) = m3.source_concept_id
			and m3.source_concept_class='Route';
commit;

begin;
drop table SITE_pcornet.imm_dose;
commit;

begin;
create table SITE_pcornet.imm_manuf as
select immunizationid,patid,encounterid,proceduresid, vx_providerid,vx_record_date, vx_admin_date, vx_code_type,
		vx_code, vx_status,vx_status_reason,vx_source, vx_dose,vx_dose_unit, vx_route,
		imm.imm_body_site_concept_id, imm.imm_body_site_source_value,
		case when imm.imm_manufacturer is null or imm.imm_manufacturer = '' then 'NI'
			else coalesce(manf_1.target_concept,manf_2.target_concept,'OTH') end as vx_manufacturer,
		vx_lot_num,vx_exp_date,raw_vx_name,raw_vx_code,raw_vx_code_type, raw_vx_dose,raw_vx_dose_unit,raw_vx_route,
		raw_vx_status,raw_vx_status_reason,site
from SITE_pcornet.imm_route imm																																				 
left join pcornet_maps.pedsnet_pcornet_valueset_map manf_1 on lower(manf_1.pcornet_name) ilike '%'||lower(imm.imm_manufacturer)||'%' and manf_1.source_concept_class = 'vx_manufacturer_source'
left join pcornet_maps.pedsnet_pcornet_valueset_map manf_2 on manf_2.source_concept_id = imm.imm_manufacturer and manf_2.source_concept_class = 'vx_manufacturer';
commit;

begin;
drop table SITE_pcornet.imm_route;
commit;

begin;
create table SITE_pcornet.imm_body_site as
select immunizationid,patid,encounterid,proceduresid,vx_providerid,vx_record_date,vx_admin_date,vx_code_type,
		vx_code,vx_status,vx_status_reason,vx_source, vx_dose,vx_dose_unit, vx_route,
		coalesce(bdy_site.target_concept,bdy_site_src.target_concept,'NI') as vx_body_site, 
		vx_manufacturer, vx_lot_num,vx_exp_date,raw_vx_name, raw_vx_code, raw_vx_code_type,raw_vx_dose,raw_vx_dose_unit,
		raw_vx_route,
		imm.imm_body_site_source_value as raw_vx_body_site,
        raw_vx_status,raw_vx_status_reason,site
from SITE_pcornet.imm_manuf imm																																				 
left join pcornet_maps.pedsnet_pcornet_valueset_map bdy_site on imm.imm_body_site_concept_id::text = bdy_site.source_concept_id and bdy_site.source_concept_class = 'imm_body_site' and bdy_site.source_concept_id is not null
left join pcornet_maps.pedsnet_pcornet_valueset_map bdy_site_src on  lower(bdy_site_src.source_concept_id) ilike '%'||lower(trim(split_part(imm_body_site_source_value,'|',1)))||'%' and bdy_site.source_concept_class = 'imm_body_site_source';
commit;

begin;
drop table SITE_pedsnet.imm_manuf;
commit;

begin;

INSERT INTO SITE_pcornet.immunization(immunizationid, patid, encounterid, proceduresid, vx_providerid,
vx_record_date, vx_admin_date, vx_code_type, vx_code, vx_status, vx_status_reason, vx_source, vx_dose,
vx_dose_unit, vx_route, vx_body_site, vx_manufacturer, vx_lot_num, vx_exp_date, raw_vx_name,
raw_vx_code, raw_vx_code_type, raw_vx_dose, raw_vx_dose_unit, raw_vx_route, raw_vx_body_site,
raw_vx_status, raw_vx_status_reason, site)
select distinct on (immunizationid)imm.immunizationid as immunizationid,
        patid,encounterid,proceduresid, vx_providerid,vx_record_date, vx_admin_date,vx_code_type,
		vx_code, vx_status,vx_status_reason,vx_source, vx_dose,vx_dose_unit, vx_route,
		vx_body_site, vx_manufacturer, vx_lot_num, vx_exp_date,raw_vx_name, raw_vx_code, raw_vx_code_type,
		raw_vx_dose,raw_vx_dose_unit,raw_vx_route,raw_vx_body_site, raw_vx_status,raw_vx_status_reason,site
from SITE_pcornet.imm_body_site imm																																				 
where imm.patid::int IN (select person_id from SITE_pcornet.person_visit_start2001);
commit;

begin;
delete from SITE_pcornet.immunization 
where encounterid IS NOT null and
	   encounterid::int NOT IN (select visit_id from SITE_pcornet.person_visit_start2001);
commit;

begin;
with not_mapping as
(
	select immunizationid from SITE_pcornet.immunization where vx_code = ''
)
update SITE_pcornet.immunization
set vx_code = coalesce(c.concept_code,'')
from not_mapping i
left join SITE_pedsnet.immunization im on im.immunization_id = i.immunizationid::int
left join vocabulary.concept c on c.concept_name @@ im.immunization_source_value
                                and concept_class_id = 'CVX'
where SITE_pcornet.immunization.immunizationid = i.immunizationid;
commit;