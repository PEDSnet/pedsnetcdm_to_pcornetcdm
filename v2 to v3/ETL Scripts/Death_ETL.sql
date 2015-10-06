set role pcor_et_user;

truncate table pcornet_cdm.death;

Insert into pcornet_cdm.death(
	patid, death_date, death_date_impute,
	death_source, death_match_confidence
)
Select
	de.person_id as patid,
	de.death_date as death_date,
	'NI' as death_impute, -- default for now until next ETL cycle
	'L' as death_source, --  default for now until next ETL cycle
	null as death_match_confidence -- null
From
	death de
	join pcornet_cdm.demographic d on d.patid = cast(de.person_id as text)
Where
	de.death_type_concept_id  = 38003569;
