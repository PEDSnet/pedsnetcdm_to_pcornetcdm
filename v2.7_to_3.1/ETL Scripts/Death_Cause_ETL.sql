Insert into dcc_3dot1_pcornet.death_cause(
	patid,
	death_cause, death_cause_code, death_cause_type,
	death_cause_source, death_cause_confidence, site
)
select 
	person_id as patid,
	left(cause_source_value,8) as death_cause,
	coalesce(m1.target_concept,'OT') as death_cause_code,
	'NI' as death_cause_type, 
	'L' as death_cause_source,
	null as death_cause_confidence, -- not dicretely captured in the EHRs
	min(de.site) as site
From
	dcc_pedsnet.death de
	join dcc_3dot1_pcornet.demographic d on cast(de.person_id as text) = d.patid
	join vocabulary.concept on cause_source_concept_id = concept_id
	left join dcc_3dot1_pcornet.pedsnet_pcornet_valueset_map m1 on cast(vocabulary_id as text) = source_concept_id 
	AND m1.source_concept_class='death cause code' 
where cause_source_value is not null and cause_source_concept_id<>44814650
group by person_id, left(cause_source_value,8), coalesce(m1.target_concept,'OT')  ; 
