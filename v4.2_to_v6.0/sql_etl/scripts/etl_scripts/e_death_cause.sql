begin;

insert into SITE_pcornet.death_cause(
	patid,death_cause, death_cause_code, death_cause_type,death_cause_source, death_cause_confidence, site
)
select
distinct
cast(person_id as text) as patid,
left(case when c.vocabulary_id in ('ICD9CM', 'ICD10','ICD10CM')
	     then c.concept_code
	     else 
 			case when c3.concept_code is not null 
 			then c3.concept_code
 		else
 			case when cause_concept_id>0
		           then c2.concept_code
	     else case when length(trim(split_part(cause_source_value,'|',3)))>0
         	       then case when trim(split_part(cause_source_value,'|',3)) like '%,%' then trim(split_part(trim(leading ',' from split_part(cause_source_value,'|',3)),',',1))
                             else trim(split_part(cause_source_value,'|',3))
					    end
         	       else trim(split_part(cause_source_value,'|',2))
         	  end
 		end
 	end
    end,8) as death_cause,
	case when c.vocabulary_id = 'ICD9CM'  then '09'
		else
 		 case when c3.vocabulary_id = 'ICD9CM'  then '09'
 		else
		case when  c.vocabulary_id in ('ICD10','ICD10CM')
		     then '10'
		          else 'OT'
		  end	
 		end
 	  end as death_cause_code,
	'NI' as death_cause_type,
	'L' as death_cause_source,
	null as death_cause_confidence,
	'SITE' as site
	from SITE_pedsnet.death d
	left join vocabulary.concept c on d.cause_source_concept_id = c.concept_id
	left join vocabulary.concept c2 on d.cause_concept_id = c2.concept_id
 	left join vocabulary.concept c3 on d.cause_source_value = c3.concept_code and c3.vocabulary_id='ICD9CM'
	where cause_source_value is not null 
	and  cause_source_concept_id<>44814650
	and cause_source_value not in ('NI', -- nemours
 	'0',-- nationwide		   
	'Z1001' --colorado
	) 
 	and not cause_source_value ~ 'IMO' --colorado
;
commit;

begin;
delete from SITE_pcornet.death_cause
where patid::int not in (select person_id from SITE_pcornet.person_visit_start2001);
commit;