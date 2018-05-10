begin;

Insert into SITE_4dot0_pcornet.provider
	(providerid, provider_sex, 
	provider_specialty_primary, provider_npi,
	provider_npi_flag, 
	raw_provider_specialty_primary, site
)
Select
	p.provider_id as providerid,
	coalesce(m1.target_concept,'OT') as provider_sex,
	coalesce(m2.target_concept,'OT') as provider_specialty_primary, 
	p.npi as provider_npi,
	case when p.npi is not null then 'Y' else 'N'  end as provider_npi_flag, 
	p.specialty_source_value as raw_provider_specialty_primary,
	p.site as site 
From
	SITE_pedsnet.provider p
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m1 on m1.source_concept_class='Gender' and
	cast(p.gender_concept_id as text) = m1.source_concept_id
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m2 on m1.source_concept_class='Provider Specialty' and
	cast(p.specialty_concept_id as text) = m1.source_concept_id ;
	
commit;