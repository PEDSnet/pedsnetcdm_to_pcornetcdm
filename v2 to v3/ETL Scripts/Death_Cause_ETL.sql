
--set role pcor_et_user;

--drop table if exists pcornet_cdm.death_cause;

set search_path to pedsnet_cdm;

Insert into pcornet_cdm.death_cause(
	patid,
	death_cause, death_cause_code, death_cause_type,
	death_cause_source, death_cause_confidence
)
select
	person_id as patid,
	cause_source_value as death_cause,
	coalesce(m1.target_concept,'OT') as death_cause_code,
	'NI' as death_cause_type, -- cannot be NULL
	'L' as death_cause_source,
	null as death_cause_confidence
From
	pedsnet_cdm.death de
	join pcornet_cdm.demographic d on cast(de.person_id as text) = d.patid
	left join pcornet_cdm.cz_omop_pcornet_concept_map m1 on cast(cause_concept_id as text) = source_concept_id
	AND m1.source_concept_class='death cause code'
where cause_concept_id>0
