
-- drug exposure --> Dispensing
-- join with demographic to make sure there are no orphan records 
-- joins with concept relationship and concept tables are to determine the mapping from RxNorm -> NDC. 

-- assuming that we have changed the datatype of dispensingid to serial
insert into pcornet_cdm.dispensing(
            patid, prescribingid, 
            dispense_date, ndc, dispense_sup, dispense_amt, raw_ndc)
with ndc_concept as (select distinct concept_id, concept_code from concept c1 where c1.concept_class_id = '11-digit NDC' and c1.vocabulary_id='NDC' and c1.invalid_reason is null)
select distinct
	cast(de.person_id as text) as patid,
	null as prescribingid, -- null for now
	de.drug_exposure_start_date as dispense_date,
	ndc_concept.concept_code as ndc,
	de.days_supply as dispense_sup,
	de.quantity as dispense_amt,
	ndc_concept.concept_code as raw_ndc
from
	drug_exposure de  
	join pcornet_cdm.demographic d on d.patid = cast(de.person_id as text) 
	join concept_relationship cr on cr.concept_id_1 = de.drug_concept_id  and cr.invalid_reason is null and  relationship_id='Mapped from'  
	join ndc_concept on cr.concept_id_2= ndc_concept.concept_id
where
	de.drug_type_concept_id = '38000175' -- Dispensing only


