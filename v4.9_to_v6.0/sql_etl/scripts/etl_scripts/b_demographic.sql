begin;

insert into SITE_pcornet.demographic (patid, birth_date, birth_time, sex, sexual_orientation, gender_identity, 
			hispanic, race, pat_pref_language_spoken, biobank_flag, raw_sex, raw_hispanic, raw_race, 
			raw_pat_pref_language_spoken, site)

with s_o_by_date as (
	select 
		row_number() over (partition by person_id, observation_date order by observation_date desc) as row_num,
		person_id,
		value_as_concept_id
	from
		SITE_pedsnet.observation
	where
		observation_concept_id = 46235214
),

s_o as (
	select 
		person_id, 
		value_as_concept_id 
	from 
		s_o_by_date
	where 
		row_num = 1
),

gender_iden_by_date as (
	select 
		row_number() over (partition by person_id, observation_date order by observation_date desc) as row_num,
		person_id,
		value_as_concept_id
	from
		SITE_pedsnet.observation
	where
		observation_concept_id = 46235215
),

gender_iden as (
	select 
		person_id, 
		value_as_concept_id 
	from 
		gender_iden_by_date
	where 
		row_num = 1
)

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
	case
		when s_o.value_as_concept_id = 36307527 then 'BI'
		when 
			s_o.value_as_concept_id = 36303203 
			and (
				(p.gender_concept_id = 8532 and (gender_iden.value_as_concept_id is null or gender_iden.value_as_concept_id in (0,45877986, 44814653,44814649,44814650 )))
				or gender_iden.value_as_concept_id = 36308665
				or gender_iden.value_as_concept_id = 36309198
				)
		then 'GA'
		when 
			s_o.value_as_concept_id = 36303203 
			and (
				(p.gender_concept_id = 8507 and (gender_iden.value_as_concept_id is null or gender_iden.value_as_concept_id in (0,45877986, 44814653,44814649,44814650 )))
				or gender_iden.value_as_concept_id = 36307702
				or gender_iden.value_as_concept_id = 36309787
				)
		then 'LE'
		when s_o.value_as_concept_id = 36310681 then 'ST'
		when s_o.value_as_concept_id = 36308454 then 'DC' 
		when s_o.value_as_concept_id = 45878142 then 'OT'
		when s_o.value_as_concept_id = 45877986 then 'UN'
		else 'NI'
	end as sexual_orientation,
	case
		when gender_iden.value_as_concept_id = 36308665 then 'M'
		when gender_iden.value_as_concept_id = 36307702 then 'F'
		when gender_iden.value_as_concept_id = 36309198 then 'TM'
		when gender_iden.value_as_concept_id = 36309787 then 'TF'
		when gender_iden.value_as_concept_id = 36309864 then 'GQ'
		when gender_iden.value_as_concept_id = 1585351 then 'GQ'
		when gender_iden.value_as_concept_id = 36308454 then 'DC' 
		when gender_iden.value_as_concept_id = 45878142 then 'OT' 
		else 'NI'
	end as gender_identity,
	coalesce (m2.target_concept,'OT') as Hispanic,
	coalesce (m3.target_concept,'OT') as Race,
	coalesce (m4.target_concept,'OT') as pat_pref_language_spoken,
	'N' as Biobank_flag,
	gender_source_value,
	ethnicity_source_value,
	race_source_value,
	language_source_value,
	'SITE' as site
from
	SITE_pedsnet.person p
	left join pcornet_maps.pedsnet_pcornet_valueset_map m1 on case when cast(p.gender_concept_id as text) is null AND m1.source_concept_id is null then true else cast(p.gender_concept_id as text) = m1.source_concept_id end and m1.source_concept_class='Gender'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m2 on case when p.ethnicity_concept_id is null AND m2.source_concept_id is null then true else cast(p.ethnicity_concept_id as text) = m2.source_concept_id end and m2.source_concept_class='Hispanic'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m3 on case when p.race_concept_id is null AND m3.source_concept_id is null then true else cast(p.race_concept_id as text) = m3.source_concept_id end and m3.source_concept_class = 'Race'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m4 on case when p.language_concept_id is null AND m4.source_concept_id is null then true else cast(p.language_concept_id as text) = m4.source_concept_id end and m4.source_concept_class = 'Language'
	left join s_o on p.person_id = s_o.person_id
	left join gender_iden on p.person_id = gender_iden.person_id
where 
	p.person_id IN (select person_id from SITE_pcornet.person_visit_start2001);

commit;
