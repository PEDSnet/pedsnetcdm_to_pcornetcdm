begin;

ALTER TABLE SITE_pcornet.provider ALTER provider_npi SET DATA TYPE NUMERIC(20,0);

Insert into SITE_pcornet.provider(providerid, provider_sex, 
provider_specialty_primary, provider_npi,provider_npi_flag, 
	raw_provider_specialty_primary, site
)
Select distinct on (p.provider_id) p.provider_id as providerid,
	coalesce(m1.target_concept,'OT') as provider_sex,
	coalesce(m.target_concept,'OT') as provider_specialty_primary, 
	null::numeric as provider_npi,
	'N' as provider_npi_flag,
	m.concept_description as raw_provider_specialty_primary,
	'SITE' as site
From
	SITE_pedsnet.provider p
	left join pcornet_maps.pedsnet_pcornet_valueset_map m1 on m1.source_concept_class='Gender' and
	cast(p.gender_concept_id as text) = m1.source_concept_id
	left join pcornet_maps.pedsnet_pcornet_valueset_map m on m.source_concept_class='Provider Specialty' 
        and case when m.source_concept_id != '' then m.source_concept_id = p.specialty_concept_id::text 
                                                else m.concept_description LIKE '%' || specialty_source_value || '%'
            end;
	
commit;
