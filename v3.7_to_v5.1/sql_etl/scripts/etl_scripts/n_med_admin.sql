begin; 

insert into SITE_pcornet.med_admin (medadminid,
            patid, encounterid,
            medadmin_start_date, medadmin_start_time, medadmin_stop_date, 
            medadmin_stop_time,
            prescribingid,
            medadmin_providerid, medadmin_type,
            medadmin_code, 
            medadmin_dose_admin, medadmin_dose_admin_unit,
            medadmin_route, medadmin_source,
            raw_medadmin_med_name, 
            raw_medadmin_code, 
            raw_medadmin_dose_admin, raw_medadmin_dose_admin_unit, 
            raw_medadmin_route
            , site
            )
select 
	drug_exposure_id as medadminid,
	cast(de.person_id as text) as patid,
	cast(de.visit_occurrence_id as text) as encounterid,
	de.drug_exposure_start_date as medadmin_start_date,
	date_part('hour',drug_exposure_start_datetime)||':'||date_part('minute',drug_exposure_start_datetime) as medadmin_start_time,
	de.drug_exposure_end_date as medadmin_stop_date,
	date_part('hour',drug_exposure_end_datetime)||':'||date_part('minute',drug_exposure_start_datetime) as medadmin_stop_time,
	null as prescribingid,
	de.provider_id as medadmin_providerid,
	coalesce(
	case 
		when ndc_via_source_concept.concept_id is not null then 'ND'
		when ndc_via_source_value.concept_id is not null then 'ND'
		when rxnorm_via_concept.concept_id > 0  then 'RX'
	end
	,'OT')
		 as medadmin_type, 
	case 
		when ndc_via_source_concept.concept_id is not null then ndc_via_source_concept.concept_code
		when ndc_via_source_value.concept_id is not null then ndc_via_source_value.concept_code
		when rxnorm_via_concept.concept_id > 0  then rxnorm_via_concept.concept_code 
	end
	as
	medadmin_code,
	de.effective_drug_dose as medadmin_dose_admin, 
	coalesce(m1.target_concept,'OT') as medadmin_dose_admin_unit,
	coalesce(m2.target_concept,'OT') as medadmin_route, 
	'OD' as medadmin_source, 
	rxnorm_via_concept.concept_name as raw_medadmin_name, 
    de.drug_concept_id as raw_medadmin_code, 
    de.eff_drug_dose_source_value as raw_medadmin_dose_admin, 
    de.dose_unit_source_value as raw_medadmin_dose_admin_unit, 
    de.route_source_value as raw_medadmin_route,
	'SITE' as site
from
	SITE_pedsnet.drug_exposure de
	left join SITE_pcornet.ndc_concepts ndc_via_source_concept on ndc_via_source_concept.concept_id = drug_source_concept_id
	left join SITE_pcornet.ndc_concepts ndc_via_source_value on ndc_via_source_value.concept_code = split_part(drug_source_value,'|',1)
	left join vocabulary.concept rxnorm_via_concept on rxnorm_via_concept.concept_id = drug_concept_id and vocabulary_id = 'RxNorm'
	left join SITE_pcornet.rx_dose_form_data rdf on de.drug_concept_id =  rdf.drug_concept_id
	left join pcornet_maps.pedsnet_pcornet_valueset_map m1 on cast(dose_unit_concept_id as text) = m1.source_concept_id 
			and m1.source_concept_class='Dose unit'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m2 on cast(de.route_concept_id as text) = m2.source_concept_id 
			and m2.source_concept_class='Route'
where
	de.drug_type_concept_id IN ('38000180')
	and de.person_id IN (select person_id from SITE_pcornet.person_visit_start2001) and EXTRACT(YEAR FROM drug_exposure_start_date) >= 2001
	and de.drug_source_value not ilike any (array['%breastmilk%','%kit%','%item%','%formula%', '%tpn%','%custom%']); 


 create index med_admin_enc on SITE_pcornet.med_admin (encounterid);

delete from SITE_pcornet.med_admin
	where
	encounterid IS not NULL
	and encounterid in (select cast(visit_occurrence_id as text) from SITE_pedsnet.visit_occurrence V where
					extract(year from visit_start_date)<2001); 
			;

commit;
