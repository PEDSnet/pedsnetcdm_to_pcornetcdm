begin;

create table if not exists SITE_pcornet.prescribing
as
select distinct
	drug_exposure_id::varchar(256) as prescribingid,
	de.person_id::varchar(256) as patid,
	de.visit_occurrence_id::varchar(256) as encounterid,
	de.provider_id as rx_providerid,
	drug_exposure_start_date as rx_order_date,
	(date_part('hour',drug_exposure_start_datetime)||':'||date_part('minute',drug_exposure_start_datetime))::varchar(5) as rx_order_time,
	drug_exposure_start_date as rx_start_date,
	drug_exposure_end_date as rx_end_date,
	round(quantity,2)::numeric(20,2) as rx_quantity,
	refills::numeric(20,2) as rx_refills,
	days_supply::numeric(20,2) as rx_days_supply,
	null::varchar(2) as rx_frequency,
	coalesce (m1.target_concept,'OT')::varchar(2) as rx_basis,
	nullif(c1.concept_code, '')::varchar(8) as rxnorm_cui,
	c1.concept_name::varchar(256) as raw_rx_med_name,
	de.frequency::varchar(256) as raw_rx_frequency,
	c2.concept_code::varchar(20) as raw_rxnorm_cui,
	de.site as site
from
	SITE_pedsnet.drug_exposure de
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m1 on case when de.drug_type_concept_id is null AND m1.source_concept_id is null
	                                                                  then true
	                                                                  else cast(de.drug_type_concept_id as text) = m1.source_concept_id
	                                                             end and
	                                                             m1.source_concept_class='prescribing'
	left join vocabulary.concept c1 on de.drug_concept_id = c1.concept_id AND
	                                   vocabulary_id = 'RxNorm'
	left join vocabulary.concept c2 on de.drug_source_concept_id = c2.concept_id
where
	de.drug_type_concept_id IN ('38000177') and
    visit_occurrence_id is not null and
    person_id in (select person_id from SITE_pcornet.person_visit_start2001) and
    visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001);

commit;