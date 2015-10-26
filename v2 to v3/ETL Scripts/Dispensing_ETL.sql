
-- drug exposure --> Dispensing
-- join with demographic to make sure there are no orphan records

--set role pcor_et_user;

--drop table if exists pcornet_cdm.dispensing;

set search_path to pedsnet_cdm;

insert into pcornet_cdm.dispensing(
            dispensingid, patid, prescribingid,
            dispense_date, ndc, dispense_sup, dispense_amt, raw_ndc)
select distinct
	de.drug_exposure_id,
	cast(de.person_id as text) as patid,
	null as prescribingid, -- null for now
	de.drug_exposure_start_date as dispense_date,
	case when c1.concept_id = 0 then 'NM'||cast(round(random()*10000000) as text) else c1.concept_code end as ndc,
	de.days_supply as dispense_sup,
	de.quantity as dispense_amt,
	c1.concept_code as raw_ndc
from
	pedsnet_cdm.drug_exposure de  -- 7.7M
	join pcornet_cdm.demographic d on d.patid = cast(de.person_id as text) --7.7M (with all above line in 9399 ms)
	join concept c1 on concept_id= de.drug_source_concept_id --
where
	de.drug_type_concept_id = '38000175' -- Dispensing only
