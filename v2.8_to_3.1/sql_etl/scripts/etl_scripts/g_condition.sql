begin;

create table if not exists SITE_pcornet.condition_occurrence
as
select condition_occurrence_id, person_id, visit_occurrence_id, condition_start_date, condition_end_date, 
       condition_type_concept_id, condition_source_concept_id, condition_concept_id, condition_source_value, site
from SITE_pedsnet.condition_occurrence
where person_id in (select person_id from SITE_pcornet.person_visit_start2001) and 
      visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001);

create table if not exists SITE_pcornet.condition
as
select distinct
	co.condition_occurrence_id::varchar(256) as conditionid,
	co.person_id::varchar(256) as patid,
	co.visit_occurrence_id::varchar(256) as encounterid,
	co.condition_start_date as report_date,
	co.condition_end_date as resolve_date,
	cast (null as date) as onset_date,
	case when condition_end_date is null
	     then 'AC'::varchar(2)
	     else 'RS'::varchar(2)
	     end as condition_status,
	(case when c2.vocabulary_id in ('ICD9CM', 'ICD10','ICD10CM')
		 then c2.concept_code
		 else case when co.condition_concept_id>0
		           then c1.concept_code
		           else trim(split_part(condition_source_value,'|',3))
		           end
	     end)::varchar(18) as condition,
	(case when c2.vocabulary_id = 'ICD9CM'  
         then '09'
		 else case when  c2.vocabulary_id in ('ICD10','ICD10CM')
		      then '10'
		      else
		      case when co.condition_concept_id> 0
		           then 'SM'
		           else 'OT'
		     end
		end
	end)::varchar(2)  as condition_type,
	'HC'::varchar(2) as condition_source,
	condition_source_value::varchar(256) as raw_condition_status,
	(concat(split_part(condition_source_value,'|',1), '|' , split_part(condition_source_value,'|',3)))::varchar(256) as raw_condition,
	c2.vocabulary_id::varchar(256) as raw_condition_type,
	null::varchar(256) as raw_condition_source ,-- it is not discretely captured in the EHRs
	co.site as site
from
	SITE_pcornet.condition_occurrence co
	join SITE_pcornet.demographic d on d.patid = cast(co.person_id as text)
	left join SITE_pcornet.encounter e on e.encounterid = cast(co.visit_occurrence_id as text)
	join vocabulary.concept c1 on co.condition_concept_id = c1.concept_id
	join vocabulary.concept c2 on co.condition_source_concept_id = c2.concept_id
    where condition_type_concept_id in ( 2000000089, 2000000090, 2000000091,38000245) and
      extract(year from co.condition_start_date) >= 2001 and
      visit_occurrence_id is not null and
      visit_occurrence_id in (select visit_occurrence_id from SITE_pedsnet.visit_occurrence where extract(year from visit_start_date)<2001);
    
commit;