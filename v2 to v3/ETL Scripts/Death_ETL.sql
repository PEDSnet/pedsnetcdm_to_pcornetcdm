Insert into dcc_pcornet.death(
	patid, death_date, death_date_impute,
	death_source, death_match_confidence, siteid
)
Select 
	de.person_id as patid,
	de.death_date as death_date,
	coalesce(m1.target_concept,'OT') as death_impute, 
	'L' as death_source, --  default for now until new conventions
	null as death_match_confidence, --  we do not capture it dicretely in the EHRs 
	site_id as siteid
From
	dcc_pedsnet.death de
	join dcc_pcornet.demographic d on d.patid = cast(de.person_id as text)
	left join dcc_pcornet.cz_omop_pcornet_concept_map m1 on m1.source_concept_class='Death date impute' and cast(de.death_impute_concept_id as text) = m1.source_concept_id
Where 
	de.death_type_concept_id  = 38003569;
