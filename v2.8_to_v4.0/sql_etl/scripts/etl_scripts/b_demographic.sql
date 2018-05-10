begin;

insert into SITE_4dot0_pcornet.demographic (patid, birth_date, birth_time, sex, hispanic, race, pat_pref_language_spoken, 
		biobank_flag, raw_sex, raw_hispanic, raw_race, 
		raw_pat_pref_language_spoken, site)
select distinct
	cast(p.person_id as text) as patid,
	cast(
	cast(year_of_birth as text)
        ||(case when month_of_birth is null then '-01' else '-'||lpad(cast(month_of_birth as text),2,'0') end)
        ||(case when day_of_birth is null then '-01' else '-'||lpad(cast(day_of_birth as text),2,'0') end)
	as date)
        as birth_date,
	LPAD(date_part('hour',birth_datetime)::text,2,'0')||':'||LPAD(date_part('minute',birth_datetime)::text,2,'0') as birth_time,
	coalesce (m1.target_concept,'OT') as Sex,
	coalesce (m2.target_concept,'OT') as Hispanic,
	coalesce (m3.target_concept,'OT') as Race,
	coalesce (m4.target_concept,'OT') as pat_pref_language_spoken,
	'N' as Biobank_flag,
	gender_source_value,
	ethnicity_source_value,
	race_source_value,
	language_source_value,
	site as site
from
	SITE_pedsnet.person p
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m1 on case when cast(p.gender_concept_id as text) is null AND m1.source_concept_id is null then true else cast(p.gender_concept_id as text) = m1.source_concept_id end and m1.source_concept_class='Gender'
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m2 on case when p.ethnicity_concept_id is null AND m2.source_concept_id is null then true else cast(p.ethnicity_concept_id as text) = m2.source_concept_id end and m2.source_concept_class='Hispanic'
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m3 on case when p.race_concept_id is null AND m3.source_concept_id is null then true else cast(p.race_concept_id as text) = m3.source_concept_id end and m3.source_concept_class = 'Race'
	left join SITE_4dot0_pcornet.pedsnet_pcornet_valueset_map m4 on case when p.language_concept_id is null AND m4.source_concept_id is null then true else cast(p.race_concept_id as text) = m3.source_concept_id end and m3.source_concept_class = 'Language'
	where person_id IN (select person_id from SITE_4dot0_pcornet.person_visit_start2001);

commit;