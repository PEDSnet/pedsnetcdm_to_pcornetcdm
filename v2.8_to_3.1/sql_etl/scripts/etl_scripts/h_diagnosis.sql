begin;

create table if not exists SITE_pcornet.diagnosis
as
select distinct
	co.condition_occurrence_id::varchar(256) as diagnosisid,
	co.person_id::varchar(256) as patid,
	co.visit_occurrence_id::varchar(256) encounterid,
	enc.enc_type,
	enc.admit_date,
	enc.providerid,
	-- look for ICDs, followed by SNOMED, following by others
	(case when c3.vocabulary_id in ('ICD9CM', 'ICD10','ICD10CM')
	     then c3.concept_code
	     else case when co.condition_concept_id>0
		           then c2.concept_code
	               else case when length(trim(split_part(condition_source_value,'|',3)))>0
         	                 then trim(split_part(condition_source_value,'|',3))
         	                 else trim(split_part(condition_source_value,'|',2))
         	            end
              end
    end)::varchar(18) as dx,
	(case when c3.vocabulary_id = 'ICD9CM'  
         then '09'
		 else case when  c3.vocabulary_id in ('ICD10','ICD10CM')
		          then '10'
		          else case when co.condition_concept_id> 0
		                    then 'SM'
		                    else 'OT'
		               end
		      end
	end)::varchar(2) as dx_type,
	coalesce(m1.target_concept,'OT')::varchar(2) as dx_source,
	coalesce(m2.target_concept, 'X')::varchar(2) as pdx,
	coalesce(m3.target_concept,'OT')::varchar(2) as dx_origin,
	(concat(split_part(condition_source_value,'|',1), '|', split_part(condition_source_value,'|',3)))::varchar(256) as raw_dx,
	(case when co.condition_source_concept_id = '44814649'
	     then 'OT'
	     else c3.vocabulary_id
	 end)::varchar(256) as raw_dx_type,
    c4.concept_name::varchar(256) as raw_dx_source,
	(case when co.condition_type_concept_id IN (2000000092, 2000000093, 2000000094, 2000000098, 2000000099, 2000000100, 38000201, 38000230)
		 then c4.concept_name
		 else NULL
     end)::varchar(256) as raw_pdx,
	co.site as site
from
	SITE_pcornet.condition_occurrence co
	join vocabulary.concept c2 on co.condition_concept_id = c2.concept_id
	join SITE_pcornet.encounter enc on co.visit_occurrence_id::varchar(256)=enc.encounterid
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m1 on m1.source_concept_class='dx_source' and
	                                                             cast(co.condition_type_concept_id as text) = m1.source_concept_id
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m2 on cast(co.condition_type_concept_id as text) = m2.source_concept_id  and
	                                                             m2.source_concept_class='pdx'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m3 on  cast(co.condition_type_concept_id as text) = m3.source_concept_id  and
	                                                              m3.source_concept_class='dx origin'
	left join vocabulary.concept c3 on co.condition_source_concept_id = c3.concept_id
	left join vocabulary.concept c4 on co.condition_type_concept_id = c4.concept_id 
where co.condition_type_concept_id not in ( 2000000089, 2000000090, 2000000091, 38000245) and
      extract(year from condition_start_date)>=2001;
      
delete from SITE_pcornet.diagnosis where length(dx) < 2;

drop table if exists SITE_pcornet.condition_occurrence;

commit;