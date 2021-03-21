begin;

Insert into SITE_pcornet.death_cause(
	patid,death_cause, death_cause_code, death_cause_type,death_cause_source, death_cause_confidence, site
)
with
dist_cause as
(
	select distinct on (cause_source_value) cause_source_value as cause_source_value_dist, concept_code || '|' ||vocabulary_id as death_cause_temp
	from SITE_pedsnet.death
	inner join vocabulary.concept c on c.concept_name = cause_source_value and vocabulary_id ilike 'ICD%'
	where cause_source_value is not null and  cause_source_concept_id<>44814650
	and cause_source_value not ilike '%|%' and length(cause_source_value) > 8
),
death_cause_derived as
(select distinct on (person_id) person_id,
coalesce(case when de.cause_source_value = '0' then '0|NULL'
		       when de.cause_source_value not ilike '%|%'  and length(de.cause_source_value) > 8
		       then dc.death_cause_temp
		       when length(trim(split_part(de.cause_source_value, '|',3))) = 0 and
                     length(trim(split_part(de.cause_source_value, '|',2))) = 0 and
                     length(trim(split_part(de.cause_source_value, '|',1))) < 8
	           then c1.concept_code||'|'||c1.vocabulary_id
               when length(trim(split_part(de.cause_source_value, '|',3))) != 0
               then case when length(sn2.concept_code) < 8 then sn2.concept_code || '|' || sn2.vocabulary_id
               when length(trim(split_part(de.cause_source_value, '|',3))) = 0 and
                    length(trim(split_part(de.cause_source_value, '|',2))) = 0 and
                    length(trim(split_part(de.cause_source_value, '|',1))) > 8
			   then c.concept_code || '|' || c.vocabulary_id
			   else left(de.cause_source_value,8) end end, left(de.cause_source_value,8)) as death_cause,
'L' as death_cause_source, 'SITE' as site, c1.concept_code, c1.vocabulary_id
From SITE_pedsnet.death de
left join vocabulary.concept c1 on c1.concept_code = trim(split_part(de.cause_source_value, '|',1))
left join vocabulary.concept c on c.concept_name = trim(split_part(de.cause_source_value, '|',1))
and c.concept_class_id ilike 'ICD%' and c.vocabulary_id ilike 'ICD%' and c.concept_code is not null
left join vocabulary.concept sn on sn.concept_code = trim(split_part(de.cause_source_value, '|',3))
left join vocabulary.concept_relationship cr on cr.concept_id_1 = sn.concept_id and relationship_id = 'Mapped from'
left join vocabulary.concept sn2 on sn2.concept_id = cr.concept_id_2 and sn2.vocabulary_id ilike 'ICD%' and sn2.concept_code is not null
left join dist_cause dc on case when de.cause_source_value not ilike '%|%'  and length(de.cause_source_value) > 8
										 then dc.cause_source_value_dist = de.cause_source_value end
where de.cause_source_value is not null and  de.cause_source_concept_id<>44814650
order by person_id, c1.concept_code,c.concept_code, sn2.concept_code ASC NULLS LAST
)
select person_id::text as patid,
split_part(death_cause,'|', 1) as death_cause,
coalesce(m1.target_concept,'OT') as death_cause_code,
'NI' as death_cause_type,
death_cause_source,
null as death_cause_confidence, -- not dicretely captured in the EHRs
de.site as site
From death_cause_derived de
left join pcornet_maps.pedsnet_pcornet_valueset_map m1 on trim(split_part(death_cause,'|', 2)) = m1.source_concept_id
															AND m1.source_concept_class='death cause code';
commit;

begin;
delete from SITE_pcornet.death_cause
where patid::int not in (select person_id from SITE_pcornet.person_visit_start2001);
commit;