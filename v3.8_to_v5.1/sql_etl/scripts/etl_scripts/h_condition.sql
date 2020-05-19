begin;

create table SITE_pcornet.filter_condition as
select * from SITE_pedsnet.condition_occurrence co
where co.condition_type_concept_id in ( 2000000089, 2000000090, 2000000091,38000245)
	and EXTRACT(YEAR FROM condition_start_date)>=2001
	and co.person_id in (select person_id from SITE_pcornet.person_visit_start2001);
commit;

begin;
create table SITE_pcornet.condition_transform as
select distinct on (co.condition_occurrence_id)('c'||co.condition_occurrence_id)::text as conditionid,
cast(co.person_id as text) as patid,
cast(co.visit_occurrence_id as text) as encounterid,
co.condition_start_date end as report_date,
co.condition_end_date as resolve_date,
cast (null as date) as onset_date,
case when condition_end_date is null then 'AC' else 'RS' end end as condition_status,
case when c2.vocabulary_id in ('ICD9CM', 'ICD10','ICD10CM') then c2.concept_code
	  else case when co.condition_concept_id>0 then c1.concept_code
	  else case when trim(split_part(condition_source_value,'|',3)) like '%,%' then trim(split_part(trim(leading ',' from split_part(condition_source_value,'|',3)),',',1))
            else trim(split_part(condition_source_value,'|',3))
end end end as condition,
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
'SITE' as site
from SITE_pcornet.filter_condition co
join vocabulary.concept c1 on co.condition_concept_id = c1.concept_id and c1.vocabulary_id ='SNOMED'
join vocabulary.concept c2 on co.condition_source_concept_id = c2.concept_id
where length(trim(split_part(condition_source_value,'|',3))) <= 18 ;
commit;

begin;

create table SITE_pcornet.filter_obs_deriv as
select * 
from SITE_pedsnet.observation_derivation_covid co
where observation_concept_id  = '2000001411' 
and value_as_concept_id in (2000001411,2000001412,2000001413) -- 42894222 removing this
and EXTRACT(YEAR FROM observation_date)>=2001
and person_id in (select person_id from SITE_pcornet.person_visit_start2001);

commit

begin;
create table SITE_pcornet.obs_deriv_transform as
select distinct on (observation_id)('o'|| observation_id)::text as conditionid,
cast(person_id as text) as patid,
cast(visit_occurrence_id as text) as encounterid,
observation_date as report_date,
cast (null as date) as resolve_date,
cast (null as date) as onset_date,
'AC'  as condition_status,
'COVID' as condition,
'AG' as condition_type,
case when observation_concept_id in (2000001411) then 'PC'
	 when observation_concept_id in (42894222) then 'PR' 
else 'HC' end as condition_source,
null as raw_condition_status,
null as raw_condition,
null as raw_condition_type,
null as raw_condition_source ,-- it is not discretely captured in the EHRs
'SITE' as site
from SITE_pcornet.filter_obs_deriv;

commit;

begin;
insert into SITE_pcornet.condition(
            conditionid, patid, encounterid, report_date, resolve_date, onset_date,
            condition_status, condition, condition_type, condition_source,
            raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site)
select ('c'||conditionid) as conditionid, patid, encounterid, report_date, resolve_date, onset_date,
        condition_status, condition, condition_type, condition_source,
        raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site
from SITE_pcornet.condition_orig-- condition_transform
union
select conditionid, patid, encounterid, report_date, resolve_date, onset_date,
        condition_status, condition, condition_type, condition_source,
        raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site
from SITE_pcornet.obs_deriv_transform;

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


begin;
update SITE_pcornet.condition
set condition = v.concept_code, 
condition_type = case when v.vocabulary_id = 'ICD9CM'  then '09'else
		case when  v.vocabulary_id in ('ICD10','ICD10CM')
		     then '10'
		     else 'OT' end end
from SITE_pcornet.condition d
inner join SITE_pedsnet.condition_occurrence c on c.condition_occurrence_id = d.conditionid::int
left join vocabulary.concept v on v.concept_code ilike trim(split_part(condition_source_value,'|',3)) and v.vocabulary_id in ('ICD10','ICD9CM','ICD10CM')
where trim(split_part(condition_source_value,'|',3)) ilike any (array['%B97.28%','%U07.1%','%B34.2%','%B34.9%','%B97.2%','%B97.21%','%J12.81%','%U04%','%U04.9%','%U07.2%','%Z20.828%'])
and d.condition_type in ('SM','OT') 
and SITE_pcornet.condition.conditionid = d.conditionid 
and SITE_pcornet.condition.condition_type in ('SM','OT');
commit;