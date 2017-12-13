begin;
insert into SITE_3dot1_pcornet.dispensing(
            dispensingid, patid, prescribingid,
            dispense_date, ndc, dispense_sup, dispense_amt, raw_ndc,site)
with
rxnorm_ndc_crosswalk as
 (
    select min(ndc_codes.concept_code) as min_ndc_code, rxnorm_codes.concept_id as rxnorm_concept_id
    from vocabulary.concept ndc_codes
	join vocabulary.concept_relationship cr on concept_id_1 = ndc_codes.concept_id and relationship_id='Maps to'
	join vocabulary.concept rxnorm_codes on concept_id_2 = rxnorm_codes.concept_id
    where ndc_codes.vocabulary_id='NDC' and rxnorm_codes.vocabulary_id='RxNorm' and  ndc_codes.concept_class_id='11-digit NDC'
    group by rxnorm_codes.concept_id
 ),
 ndc_concepts as
 (
    select concept_code, concept_id
    from  vocabulary.concept
    where vocabulary_id='NDC'
 )
select distinct
	de.drug_exposure_id,
	cast(de.person_id as text) as patid,
	null as prescribingid,
	de.drug_exposure_start_date as dispense_date,
	COALESCE(ndc.concept_code, rxnorm_ndc_crosswalk.min_ndc_code,
			split_part(drug_source_value,'|',1))
		 as ndc,
	de.days_supply as dispense_sup,
	de.quantity as dispense_amt,
	drug_source_value as raw_ndc,
	de.site as site
from
	SITE_pedsnet.drug_exposure de
	join SITE_3dot1_pcornet.demographic d on d.patid = cast(de.person_id as text)
	left join rxnorm_ndc_crosswalk on drug_concept_id = rxnorm_concept_id
	left join ndc_concepts ndc on concept_id = drug_source_concept_id
where
	de.drug_type_concept_id = '38000175'
	and ( rxnorm_ndc_crosswalk.min_ndc_code is not null
		or  ndc.concept_id is not null
		or  split_part(drug_source_value,'|',1) in (
		                                             select concept_code
		                                             from ndc_concepts
		                                           )
		);
commit;