begin;
ALTER TABLE SITE_3dot1_pcornet.prescribing ALTER raw_rxnorm_cui SET DATA TYPE character varying(20);
alter table SITE_3dot1_pcornet.prescribing alter rxnorm_cui SET DATA TYPE character varying(8);
ALTER TABLE SITE_3dot1_pcornet.prescribing ALTER rx_quantity SET DATA TYPE NUMERIC(20,2);
ALTER TABLE SITE_3dot1_pcornet.prescribing ALTER rx_refills SET DATA TYPE NUMERIC(20,2);
ALTER TABLE SITE_3dot1_pcornet.prescribing ALTER rx_days_supply SET DATA TYPE NUMERIC(20,2);


insert into SITE_3dot1_pcornet.prescribing (prescribingid,
            patid, encounterid,
            rx_providerid, rx_order_date, rx_order_time,
            rx_start_date, rx_end_date, rx_quantity, rx_refills, rx_days_supply, rx_frequency, rx_basis,
            rxnorm_cui,
            raw_rx_med_name, raw_rx_frequency, raw_rxnorm_cui,site)
select distinct
	drug_exposure_id as prescribingid,
	cast(de.person_id as text) as patid,
	cast(visit_occurrence_id as text) as encounterid,
	de.provider_id as rx_providerid,
	drug_exposure_start_date as rx_order_date,
	date_part('hour',drug_exposure_start_datetime)||':'||date_part('minute',drug_exposure_start_datetime) as rx_order_time,
	drug_exposure_start_date as rx_start_date,
	drug_exposure_end_date as rx_end_date,
	round(quantity,2) as rx_quantity,
	refills as rx_refills,
	days_supply as rx_days_supply,
	null as rx_frequency,
	coalesce (m1.target_concept,'OT') as rx_basis,
	CAST(nullif(c1.concept_code, '') AS integer) as rxnorm_cui,
	c1.concept_name as raw_rx_med_name,
	de.frequency as raw_rx_frequency,
	c2.concept_code as raw_rxnorm_cui,
	de.site as site
from
	SITE_pedsnet.drug_exposure de
	left join SITE_3dot1_pcornet.pedsnet_pcornet_valueset_map m1 on case when de.drug_type_concept_id is null AND m1.source_concept_id is null
	                                                                     then true
	                                                                     else cast(de.drug_type_concept_id as text) = m1.source_concept_id
	                                                                end and
	                                                                m1.source_concept_class='prescribing'
	left join vocabulary.concept c1 on de.drug_concept_id = c1.concept_id AND
	                                      vocabulary_id = 'RxNorm'
	left join vocabulary.concept c2 on de.drug_source_concept_id = c2.concept_id
where
	de.drug_type_concept_id IN ('38000177');
commit;