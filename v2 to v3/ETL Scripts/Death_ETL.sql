Insert into pcornet_cdm.death(
	patid, death_date, death_date_impute,
	death_source, death_match_confidence	
)
Select 
	de.person_id as patid,
	de.death_date as death_date,
	'N' as death_impute, -- No for now, where to store this information in PEDSnet CDM?
	'L' as death_source, -- death data from the EHR
	null as death_match_confidence -- null since records are not from an external source. Possibly record linkage use case
From
	death de
	join pcornet_cdm.demographic d on d.patid = cast(de.person_id as text)
Where 
	de.death_type_concept_id  = 38003569;
	 
