INSERT INTO test.immunization(immunizationid, patid, encounterid, procedureid, vx_providerid,
vx_record_date, vx_admin_date, vx_code_type, vx_code, vx_status, vx_status_reason, vx_source, vx_dose,
vx_dose_unit, vx_route, vx_body_site, vx_manufacturer, vx_lot_num, vx_exp_date, raw_vx_name,
raw_vx_code, raw_vx_code_type, raw_vx_dose, raw_vx_dose_unit, raw_vx_route, raw_vx_body_site,
raw_vx_status, raw_vx_status_reason, site)
select imm.immunization_id::text as immunizationid,
        imm.person_id::text as patid,
		imm.visit_occurrence_id::text as encounterid,
		imm.procedure_occurrence_id::text as procedureid,
		imm.provider_id::text as vx_providerid,
		imm.imm_recorded_date  as vx_record_date,
		imm.immunization_date as vx_admin_date,
		coalesce(m1.target_concept, 'OT') as vx_code_type,
		case when imm.immunization_concept_id = 0 then trim(split_part(imm.immunization_source_value,'|',2))
				 else c.concept_code end  as vx_code,
		'CP' as vx_status,
		null as vx_status_reason,
		null as vx_source, -- immunization_type_concept_id and valueset maps need to should be used
		NULLIF(regexp_replace(imm.immunization_dose, '[^0-9.]*','','g'), '')::numeric as vx_dose,
		coalesce(m2.target_concept, 'OT') as vx_dose_unit,
		coalesce(m3.target_concept, 'OT') as vx_route,
		'NI' as vx_body_site, -- imm_body_site_concept_id or imm_body_site_source_value should be used to populate
		imm.imm_manufacturer as vx_manufacturer,
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
		imm.site
from dcc_pedsnet.immunization imm
left join vocabulary.concept c on c.concept_id = imm.immunization_concept_id
left join pcornet_maps.imm_code_type_map m1 on m1.source_concept_id = c.vocabulary_id and m1.source_concept_class = 'immunization_type'
left join pcornet_maps.pedsnet_pcornet_valueset_map m2 on cast(imm_dose_unit_concept_id as text) = m2.source_concept_id
			and m2.source_concept_class='Dose unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map m3 on cast(imm_route_concept_id as text) = m3.source_concept_id
			and m3.source_concept_class='Route'
where
	person_id IN (select person_id from SITE_pcornet.person_visit_start2001)
	and visit_occurrence_id IN (select visit_id from SITE_pcornet.person_visit_start2001)