begin;

insert into SITE_pcornet.diagnosis(
            diagnosisid,patid, encounterid, enc_type, admit_date, providerid, dx, dx_type,
            dx_source, pdx, dx_origin, raw_dx, raw_dx_type, raw_dx_source, raw_pdx,site, dx_poa)
select distinct
	cast(co.condition_occurrence_id as text) as diagnosisid,
	cast(co.person_id as text) as patid,
	cast(co.visit_occurrence_id as text) encounterid,
	enc.enc_type,
	enc.admit_date,
	enc.providerid,
	-- look for ICDs, followed by SNOMED, following by others
	case when c3.vocabulary_id in ('ICD9CM', 'ICD10','ICD10CM')
	     then c3.concept_code
	     else case when co.condition_concept_id>0
		           then c2.concept_code
	     else case when length(trim(split_part(condition_source_value,'|',3)))>0
         	       then case when trim(split_part(condition_source_value,'|',3)) like '%,%' then trim(split_part(trim(leading ',' from split_part(condition_source_value,'|',3)),',',1))
                             else trim(split_part(condition_source_value,'|',3))
					    end
         	       else trim(split_part(condition_source_value,'|',2))
         	  end
         end
    end as dx,
	case when c3.vocabulary_id = 'ICD9CM'  then '09'
		else
		case when  c3.vocabulary_id in ('ICD10','ICD10CM')
		     then '10'
		     else
		     case when co.condition_concept_id> 0
		          then 'SM'
		          else 'OT'
		     end
		end
	end as dx_type,
	coalesce(m1.target_concept,'OT') as dx_source,
	coalesce(m2.target_concept, 'X') as pdx,
	coalesce(m3.target_concept,'OT') as dx_origin,
	concat(split_part(condition_source_value,'|',1), '|', split_part(condition_source_value,'|',3)) as raw_dx,
	case when co.condition_source_concept_id = '44814649'
	     then 'OT'
	     else c3.vocabulary_id
	     end as raw_dx_type,
    c4.concept_name as raw_dx_source,
	case when co.condition_type_concept_id IN (2000000092, 2000000093, 2000000094, 2000000098, 2000000099, 2000000100, 38000201, 38000230)
		 then c4.concept_name
		 else NULL
		 end as raw_pdx,
	co.site as site,
	coalesce(m4.target_concept,'OT') as dx_poa
from
	SITE_pedsnet.condition_occurrence co
	join vocabulary.concept c2 on co.condition_concept_id = c2.concept_id
	join SITE_pcornet.encounter enc on cast(co.visit_occurrence_id as text)=enc.encounterid
	left join pcornet_maps.pedsnet_pcornet_valueset_map m1 on m1.source_concept_class='dx_source' and
	                                                                cast(co.condition_type_concept_id as text) = m1.source_concept_id
	left join pcornet_maps.pedsnet_pcornet_valueset_map m2 on  cast(co.condition_type_concept_id as text) = m2.source_concept_id  and
	                                                                 m2.source_concept_class='pdx'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m3 on  cast(co.condition_type_concept_id as text) = m3.source_concept_id  and
	                                                                 m3.source_concept_class='dx origin'
	left join vocabulary.concept c3 on co.condition_source_concept_id = c3.concept_id
	left join vocabulary.concept c4 on co.condition_type_concept_id = c4.concept_id
	left join pcornet_maps.pedsnet_pcornet_valueset_map m4 on  cast(co.poa_concept_id as text) = m4.source_concept_id  and
	                                                                 m4.source_concept_class='dx_poa'
where
	co.condition_type_concept_id not in ( 2000000089, 2000000090, 2000000091, 38000245)
	and visit_occurrence_id IN (select visit_id from SITE_pcornet.person_visit_start2001)
	and extract (year from condition_start_date) >=2001 ;

commit;

begin;

delete from SITE_pcornet.diagnosis
where length(dx) < 2;

commit;