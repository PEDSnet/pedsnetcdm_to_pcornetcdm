begin;

ALTER TABLE SITE_pcornet.prescribing ALTER raw_rxnorm_cui SET DATA TYPE character varying(20);
alter table SITE_pcornet.prescribing alter rxnorm_cui SET DATA TYPE character varying(8);
ALTER TABLE SITE_pcornet.prescribing ALTER rx_quantity SET DATA TYPE NUMERIC(20,2);
ALTER TABLE SITE_pcornet.prescribing ALTER rx_refills SET DATA TYPE NUMERIC(20,2);
ALTER TABLE SITE_pcornet.prescribing ALTER rx_days_supply SET DATA TYPE NUMERIC(20,2);
ALTER TABLE SITE_pcornet.prescribing ALTER rx_dose_ordered SET DATA TYPE NUMERIC(20,2);

--drop table SITE_pcornet.rx_dose_form_data ;

create  table SITE_pcornet.rx_dose_form_data
as
(
  select distinct de.drug_concept_id, c.concept_id as rx_dose_form_concept_id, c.concept_name as rx_dose_form_concept_name
  from SITE_pedsnet.drug_exposure de, vocabulary.concept_relationship cr, 
  vocabulary.concept c  
  where de.drug_type_concept_id IN (38000177, 38000180,581373)
  and drug_concept_id > 0 
  and relationship_id = 'RxNorm has dose form'
  and de.drug_concept_id = concept_id_1
  and concept_id_2 = c.concept_id
); 

CREATE INDEX idx_drug_concept_id ON SITE_pcornet.rx_dose_form_data (drug_concept_id);
 
insert into SITE_pcornet.prescribing (prescribingid,
            patid, encounterid,
            rx_providerid, rx_order_date, rx_order_time,
            rx_start_date, rx_end_date, rx_dose_ordered, rx_dose_ordered_unit, 
            rx_dose_form, 
            rx_quantity, rx_refills, rx_days_supply, rx_frequency, 
            rx_prn_flag, rx_route,
            rx_basis,
            rxnorm_cui, rx_source, rx_dispense_as_written,
            raw_rx_med_name, raw_rx_frequency, raw_rxnorm_cui,
            raw_rx_dose_ordered, raw_rx_dose_ordered_unit, 
            raw_rx_route, raw_rx_refills, site)
select
	drug_exposure_id as prescribingid,
	cast(de.person_id as text) as patid,
	cast(de.visit_occurrence_id as text) as encounterid,
	de.provider_id as rx_providerid,
	de.drug_exposure_start_date as rx_order_date,
	date_part('hour',drug_exposure_start_datetime)||':'||date_part('minute',drug_exposure_start_datetime) as rx_order_time,
	drug_exposure_start_date  as rx_start_date,
	drug_exposure_end_date as rx_end_date,
	effective_drug_dose as rx_dose_ordered,
	coalesce(m1.target_concept,'OT') as rx_dose_ordered_unit,
	coalesce(m2.target_concept,'OT') as rx_dose_form,
	round(quantity,2) as rx_quantity,
	refills as rx_refills,
	days_supply as rx_days_supply,
	coalesce (m3.target_concept,'OT') as rx_frequency,
	case when trim(lower(frequency)) like '%as needed%' or trim(lower(frequency)) like '%prn%'
		then 'Y' else 'N'
	end	as rx_prn_flag, 
	coalesce(m4.target_concept,'OT') as rx_route, 
	case when drug_type_concept_id = '38000177' then '01' when drug_type_concept_id = '581373' then '02' else 'NI' end as rx_basis,
	CAST(nullif(c1.concept_code, '') AS integer) as rxnorm_cui,
	'OD' as rx_source, 
	coalesce(m5.target_concept,'OT') as rx_dispense_as_written, -- extracting from pedsnet dispense_as_written_concept_id column data in pcornet valueset
	case when (c1.concept_name is null) then split_part(drug_source_value,'|',1) --- extract from drug source value
		 else c1.concept_name
		 end as raw_rx_med_name,
	de.frequency as raw_rx_frequency,
	c2.concept_code as raw_rxnorm_cui,
	eff_drug_dose_source_value as raw_rx_dose_ordered,
	dose_unit_source_value as raw_rx_dose_ordered_unit,
	route_source_value as raw_rx_route,
	de.refills as raw_rx_refills,
	'SITE' as site
from
	SITE_pedsnet.drug_exposure de
	left join vocabulary.concept c1 on de.drug_concept_id = c1.concept_id AND
	                                   vocabulary_id = 'RxNorm'
	left join vocabulary.concept c2 on de.drug_source_concept_id = c2.concept_id
	left join SITE_pcornet.rx_dose_form_data rdf on de.drug_concept_id =  rdf.drug_concept_id
	left join pcornet_maps.pedsnet_pcornet_valueset_map m1 on cast(dose_unit_concept_id as text) = m1.source_concept_id 
			                                               and m1.source_concept_class='Dose unit'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m2 on cast(rdf.rx_dose_form_concept_id as text) = m2.source_concept_id 
			                                               and m2.source_concept_class='Rx Dose Form'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m3 on cast(trim(lower(de.frequency)) as text) = m3.source_concept_id 
			                                               and m3.source_concept_class='Rx Frequency'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m4 on cast(de.route_concept_id as text) = m4.source_concept_id 
			                                               and m4.source_concept_class='Route'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m5 on  cast(de.dispense_as_written_concept_id as text) = m5.source_concept_id  and
	                                                                 m5.source_concept_class='dispense written'
where
	de.drug_type_concept_id IN ('38000177','581373')
	and de.person_id IN (select person_id from SITE_pcornet.person_visit_start2001)
	and EXTRACT(YEAR FROM drug_exposure_start_date) >= 2001
        and de.drug_source_value not ilike any (array['%breastmilk%','%kit%','%item%','%formula%', '%tpn%','%custom%']);
commit;
 
begin;

CREATE INDEX idx_pres_encid ON SITE_pcornet.prescribing (encounterid);


delete from SITE_pcornet.prescribing
where encounterid IS not NULL
	and encounterid  in (select cast(visit_occurrence_id as text) from SITE_pedsnet.visit_occurrence V where
					extract(year from visit_start_date)<2001);

commit;
