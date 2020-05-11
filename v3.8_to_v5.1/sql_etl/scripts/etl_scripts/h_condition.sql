begin;

create table SITE_pcornet.filter_condition as
select * from SITE_pedsnet.condition_occurrence co
where co.condition_type_concept_id in ( 2000000089, 2000000090, 2000000091,38000245)
	and EXTRACT(YEAR FROM condition_start_date)>=2001
	and co.person_id in (select person_id from SITE_pcornet.person_visit_start2001);
commit;

begin;
Alter table SITE_pcornet.condition add column condition_code character varying(256);
commit;

begin;
insert into SITE_pcornet.condition(
            conditionid, patid, encounterid, report_date, resolve_date, onset_date,
            condition_status, condition, condition_type, condition_source,
            raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site,condition_code)
select distinct on (co.condition_occurrence_id)co.condition_occurrence_id::text as conditionid,
	cast(co.person_id as text) as patid,
	cast(co.visit_occurrence_id as text) as encounterid,
	Case when observation_concept_id in (2000001411) 
	     then observation_date
	     else co.condition_start_date end as report_date,
	co.condition_end_date as resolve_date,
	cast (null as date) as onset_date,
	case when observation_concept_id in (2000001411) 
	     then 'AC' else
	     case when condition_end_date is null
	     then 'AC'
	     else 'RS'
	     end end as condition_status,
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
	case when observation_concept_id in (2000001411) then 'PC'
		 when observation_concept_id in (42894222) then 'PR' 
		 else 'HC' 
		 end as condition_source,
	condition_status_source_value as raw_condition_status,
	concat(split_part(condition_source_value,'|',1), '|' , split_part(condition_source_value,'|',3)) as raw_condition,
	c2.vocabulary_id as raw_condition_type,
	null as raw_condition_source ,-- it is not discretely captured in the EHRs
	'SITE' as site,
	case when observation_concept_id in (2000001411) 
	     then 'COVID'
		 else null
		 end as condition_code
from SITE_pcornet.filter_condition co
	join vocabulary.concept c1 on co.condition_concept_id = c1.concept_id and c1.vocabulary_id ='SNOMED'
	join vocabulary.concept c2 on co.condition_source_concept_id = c2.concept_id
	left join SITE_pedsnet.observation obs on obs.person_id = co.person_id and obs.observation_concept_id in (2000001411, 42894222)
where length(trim(split_part(condition_source_value,'|',3))) <= 18 ;

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
