/*
		filter the start2001 visit patients
		death_source: defaulted to null as of now until new conventions
		death_match_confidence: we do not capture it directly in EHRs
		site: retrive one record incase multiple death causes
*/

-- filter
create table if not exists SITE_pcornet.death_P
as
select person_id::varchar(256), death_date, death_impute_concept_id, 
       death_type_concept_id, cause_source_value, cause_source_concept_id, site
from SITE_pedsnet.death
where person_id in (select person_id from SITE_pcornet.person_visit_start2001);

-- Extract and transform
create table if not exists SITE_pcornet.death
as
select
	de.person_id as patid,
	de.death_date as death_date,
	coalesce(m1.target_concept,'OT')::varchar(2) as death_impute,
	'L'::varchar(2) as death_source,
	null::varchar(2) as death_match_confidence, 
	min(de.site)::varchar(32) as site
from
	SITE_pcornet.death_p de
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m1 on m1.source_concept_class='Death date impute' and
	cast(de.death_impute_concept_id as text) = m1.source_concept_id
where
	de.death_type_concept_id  = 38003569
group by de.person_id , de.death_date, coalesce(m1.target_concept,'OT');