begin;
Insert into SITE_3dot1_pcornet.death(
	patid, death_date, death_date_impute,
	death_source, death_match_confidence, site
)
Select
	de.person_id as patid,
	de.death_date as death_date,
	coalesce(m1.target_concept,'OT') as death_impute,
	'L' as death_source, --  default for now until new conventions
	null as death_match_confidence, --  we do not capture it dicretely in the EHRs
	min(de.site) as site -- retrieve one record in case of multiple death causes
From
	SITE_pedsnet.death de
	left join SITE_3dot1_pcornet.pedsnet_pcornet_valueset_map m1 on m1.source_concept_class='Death date impute' and
	cast(de.death_impute_concept_id as text) = m1.source_concept_id
Where
	de.death_type_concept_id  = 38003569
group by de.person_id , de.death_date, coalesce(m1.target_concept,'OT');
commit;