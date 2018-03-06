begin;

create table if not exists SITE_pcornet.death_cause
as
select
	person_id as patid,
	left(cause_source_value,8)::varchar(8) as death_cause,
	coalesce(m1.target_concept,'OT')::varchar(2) as death_cause_code,
	'NI'::varchar(2) as death_cause_type,
	'L'::varchar(2) as death_cause_source,
	null::varchar(2) as death_cause_confidence, -- not dicretely captured in the EHRs
	min(de.site)::varchar(32) as site
From
	SITE_pcornet.death_p de
	join SITE_pcornet.demographic d on cast(de.person_id as text) = d.patid
	join vocabulary.concept on cause_source_concept_id = concept_id
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m1 on cast(vocabulary_id as text) = source_concept_id
	                                                          and m1.source_concept_class='death cause code'
where cause_source_value is not null and
      cause_source_concept_id<>44814650
group by person_id, left(cause_source_value,8), coalesce(m1.target_concept,'OT');

drop table if exists SITE_pcornet.death_p;

commit;