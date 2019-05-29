begin;

insert into SITE_pcornet.condition(
            conditionid, patid, encounterid, report_date, resolve_date, onset_date,
            condition_status, condition, condition_type, condition_source,
            raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site)
select distinct
	cast(co.condition_occurrence_id as text) as conditionid,
	cast(co.person_id as text) as patid,
	cast(co.visit_occurrence_id as text) as encounterid,
	co.condition_start_date as report_date,
	co.condition_end_date as resolve_date,
	cast (null as date) as onset_date,
	case when condition_end_date is null
	     then 'AC'
	     else 'RS'
	     end as condition_status,
	case when c2.vocabulary_id in ('ICD9CM', 'ICD10','ICD10CM')
		then
		c2.concept_code
		else case when co.condition_concept_id>0
		          then c1.concept_code
		          else case when trim(split_part(condition_source_value,'|',3)) like '%,%' then trim(split_part(trim(leading ',' from split_part(condition_source_value,'|',3)),',',1))
                             else trim(split_part(condition_source_value,'|',3))
					    end
		          end
	end
	 as condition,
	case when c2.vocabulary_id = 'ICD9CM'  then '09'
		else
		case when  c2.vocabulary_id in ('ICD10','ICD10CM')
		     then '10'
		     else
		     case when co.condition_concept_id> 0
		          then 'SM'
		          else 'OT'
		     end
		end
	end  as condition_type,
	'HC' as condition_source,
	condition_status_source_value as raw_condition_status,
	concat(split_part(condition_source_value,'|',1), '|' , split_part(condition_source_value,'|',3)) as raw_condition,
	c2.vocabulary_id as raw_condition_type,
	null as raw_condition_source ,-- it is not discretely captured in the EHRs
	co.site as site
from
	SITE_pedsnet.condition_occurrence co
	join vocabulary.concept c1 on co.condition_concept_id = c1.concept_id
	join vocabulary.concept c2 on co.condition_source_concept_id = c2.concept_id
where
	co.condition_type_concept_id in ( 2000000089, 2000000090, 2000000091,38000245)
	and EXTRACT(YEAR FROM condition_start_date)>=2001
	and person_id in (select person_id from SITE_pcornet.person_visit_start2001)
        and length(trim(split_part(condition_source_value,'|',3))) <= 18; 
commit;	
begin;
CREATE INDEX idx_cond_encid ON SITE_pcornet.condition (encounterid);
commit;
begin;		
delete from SITE_pcornet.condition where
	 encounterid is not null 
	and 
	encounterid in
        (select cast(visit_occurrence_id as text) 	from SITE_pedsnet.visit_occurrence
        where 
        EXTRACT(YEAR FROM visit_start_date) < 2001);
commit;
