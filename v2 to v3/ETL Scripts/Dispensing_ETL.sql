
-- drug exposure --> Dispensing

-- assuming that we have changed the datatype of dispensingid to serial
insert into pcornet_cdm.dispensing(
            patid, prescribingid, 
            dispense_date, ndc, dispense_sup, dispense_amt, raw_ndc)
select distinct
	cast(de.person_id as text) as patid,
	null as prescribingid, -- null for now
	de.drug_exposure_start_date as dispense_date,
	c1.concept_code as ndc,
	de.days_supply as dispense_sup,
	de.quantity as dispense_amt,
	c1.concept_code as raw_ndc
from
	drug_exposure de
	join pcornet_cdm.demographic d on d.patid = cast(de.person_id as text)
	join concept_relationship cr on concept_id_1 = de.drug_concept_id and cr.invalid_reason is null and  relationship_id='Mapped from'
	join concept c1 on cr.concept_id_2 = c1.concept_id AND c1.concept_class_id = '11-digit NDC' and c1.vocabulary_id='NDC' and c1.invalid_reason is null 
where
	de.drug_type_concept_id = '38000175' -- Dispensing only

