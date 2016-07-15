
-- drug exposure --> Dispensing
-- join with demographic to make sure there are no orphan records 

-- more changes likely to be made based on Data Models #202
insert into dcc_pcornet.dispensing(
            dispensingid, patid, prescribingid, 
            dispense_date, ndc, dispense_sup, dispense_amt, raw_ndc)
select distinct
	de.drug_exposure_id,
	cast(de.person_id as text) as patid,
	null as prescribingid, -- null for now until some decision in Data Models #202
	de.drug_exposure_start_date as dispense_date,
	case when c1.vocabulary_id='NDC' then c1.concept_code else 'NM'||cast(round(random()*10000000) as text)  end as ndc,
	de.days_supply as dispense_sup,
	de.quantity as dispense_amt,
	case when c1.vocabulary_id='NDC' then c1.concept_code else null end as raw_ndc
from
	dcc_pedsnet.drug_exposure de  
	join dcc_pcornet.demographic d on d.patid = cast(de.person_id as text) 
	join vocabulary.concept c1 on concept_id= de.drug_source_concept_id 
where	
	de.drug_type_concept_id = '38000175' -- Dispensing only


