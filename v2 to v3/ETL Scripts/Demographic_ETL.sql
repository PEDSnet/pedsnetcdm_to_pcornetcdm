-- Person -> Demographic
-- Changes from previous version:
-- Change these two rows from Biobank flag mappings

-- N|Biobank flag|4001345|44814650|No information
-- N|Biobank flag|4001345|44814653|Unknown

-- Reason: Use generic concept ID for No information and Unknown.

insert into pcornet_cdm.demographic (patid, birth_date, birth_time, sex, hispanic, race, biobank_flag, raw_sex, raw_hispanic, raw_race)
select distinct 
	cast(p.person_id as text) as pat_id,
	cast(
	cast(year_of_birth as text)
        ||(case when month_of_birth is null then '-01' else '-'||lpad(cast(month_of_birth as text),2,'0') end)
        ||(case when day_of_birth is null then '-01' else '-'||lpad(cast(day_of_birth as text),2,'0') end)
	as date)
        as birth_date,
	date_part('hour',time_of_birth)||':'||date_part('minute',time_of_birth) as birth_time,
	coalesce (m1.target_concept,'OT') as Sex,
	coalesce (m2.target_concept,'OT') as Hispanic,
	coalesce (m3.target_concept,'OT') as Race,
	case when o.person_id is null then 'N' else coalesce (m4.target_concept,'N') end as Biobank_flag,
	gender_source_value,
	ethnicity_source_value,
	race_source_value
from
	person p
	left join observation o on p.person_id = o.person_id and observation_concept_id = 4001345
	left join pcornet_cdm.cz_omop_pcornet_concept_map m1 on case when cast(p.gender_concept_id as text) is null AND m1.source_concept_id is null then true else cast(p.gender_concept_id as text) = m1.source_concept_id end and m1.source_concept_class='Gender'
	left join pcornet_cdm.cz_omop_pcornet_concept_map m2 on case when p.ethnicity_concept_id is null AND m2.source_concept_id is null then true else cast(p.ethnicity_concept_id as text) = m2.source_concept_id end and m2.source_concept_class='Hispanic'
	left join pcornet_cdm.cz_omop_pcornet_concept_map m3 on case when p.race_concept_id is null AND m3.source_concept_id is null then true else cast(p.race_concept_id as text) = m3.source_concept_id end and m3.source_concept_class = 'Race'
	left join pcornet_cdm.cz_omop_pcornet_concept_map m4 on case when o.value_as_concept_id is null AND m4.value_as_concept_id is null then true else o.value_as_concept_id=m4.value_as_concept_id end and m4.source_concept_class = 'Biobank flag'


