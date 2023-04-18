/* ensure effective drug dosage number fits within numeric(15,8)
If total number of digits > 15, truncate decimal places if able to */
begin;
update 
	SITE_pedsnet.drug_exposure
set 
	effective_drug_dose = trunc(effective_drug_dose, (15 - length(split_part(effective_drug_dose::text, '.', 1))))
where
	length(effective_drug_dose::text) - 1 > 15
	and length(split_part(effective_drug_dose::text, '.', 2)) > (15 - length(split_part(effective_drug_dose::text, '.', 1)));
commit;

begin;


create table SITE_pcornet.rxnorm_ndc_crosswalk as
 (
    select min(ndc_codes.concept_code) as min_ndc_code, rxnorm_codes.concept_id as rxnorm_concept_id
    from vocabulary.concept ndc_codes
	join vocabulary.concept_relationship cr on concept_id_1 = ndc_codes.concept_id and relationship_id='Maps to'
	join vocabulary.concept rxnorm_codes on concept_id_2 = rxnorm_codes.concept_id
    where ndc_codes.vocabulary_id='NDC' and rxnorm_codes.vocabulary_id='RxNorm' and  ndc_codes.concept_class_id='11-digit NDC'
    group by rxnorm_codes.concept_id
 ); 
 
 create table SITE_pcornet.ndc_concepts as
 (
    select concept_code, concept_id
    from  vocabulary.concept
    where vocabulary_id='NDC'
 ); 
 
 insert into SITE_pcornet.dispensing( dispensingid, patid, prescribingid, dispense_date,
                                        ndc, dispense_sup, dispense_amt, dispense_dose_disp, 
                                        dispense_dose_disp_unit, dispense_route, dispense_source, raw_ndc,
                                        raw_dispense_dose_disp, raw_dispense_dose_disp_unit, raw_dispense_route, site)
select distinct
	de.drug_exposure_id,
	de.person_id::varchar(256) as patid,
	null::varchar(256) as prescribingid,
	de.drug_exposure_start_date as dispense_date,
	COALESCE(ndc.concept_code, rxnorm_ndc_crosswalk.min_ndc_code,
			split_part(drug_source_value,'|',1))
		 as ndc,
	case when de.days_supply = 0 then null   --
	     else de.days_supply
	end as dispense_sup,
	de.quantity as dispense_amt,
	de.effective_drug_dose as dispense_dose_disp, 
	coalesce(m1.target_concept,'OT') as dispense_dose_disp_unit,
	coalesce(m2.target_concept,'OT') as dispense_route,
	'PM' as dispense_source, -- defaulting it to sourced from pharmacy
	drug_source_value as raw_ndc,
	eff_drug_dose_source_value as raw_dispense_dose_disp, 
	dose_unit_source_value as raw_dispense_dose_disp_unit,
	route_source_value as raw_dispense_route,
	'SITE' as site
from
	SITE_pedsnet.drug_exposure de
	left join SITE_pcornet.rxnorm_ndc_crosswalk on drug_concept_id = rxnorm_concept_id
	left join SITE_pcornet.ndc_concepts ndc on concept_id = drug_source_concept_id
	left join pcornet_maps.pedsnet_pcornet_valueset_map m1 on cast(dose_unit_concept_id as text) = m1.source_concept_id 
			and m1.source_concept_class='Dose unit'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m2 on cast(route_concept_id as text) = m2.source_concept_id 
			and m2.source_concept_class='Route'
where
	de.drug_type_concept_id = '38000175' and
    person_id in (select person_id from SITE_pcornet.person_visit_start2001) and
	( rxnorm_ndc_crosswalk.min_ndc_code is not null
		or  ndc.concept_id is not null
		or  split_part(drug_source_value,'|',1) in (
		                                             select concept_code
		                                             from SITE_pcornet.ndc_concepts ))
and de.drug_source_value not ilike any (array['%UNDILUTED DILUENT%','%KCAL/OZ%','%breastmilk%','%kit%','%item%','%formula%', '%tpn%','%custom%','%parenteral nutrition%','%ZZBREAST MILK%','%FAT EMULSION%']);

commit;
