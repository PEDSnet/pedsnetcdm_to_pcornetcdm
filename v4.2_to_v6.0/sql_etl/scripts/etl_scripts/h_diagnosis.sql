begin;
create table SITE_pcornet.filter_diag as
select * 
from SITE_pedsnet.condition_occurrence co
where
	co.condition_type_concept_id not in ( 2000000089, 2000000090, 2000000091, 38000245)
	and not condition_source_value ~ 'NOD.X';
commit;

-- begin;
-- CREATE INDEX idx_filtdia_encid
--     ON SITE_pcornet.filter_diag USING btree
--     (visit_occurrence_id )
--     TABLESPACE pg_default;

-- CREATE INDEX idx_filtdia_patid
--     ON SITE_pcornet.filter_diag USING btree
--     (person_id )
--     TABLESPACE pg_default;
	
-- CREATE INDEX idx_filtdia_diagid
--     ON SITE_pcornet.filter_diag USING btree
--     (condition_occurrence_id )
--     TABLESPACE pg_default;
	
-- commit;

begin;

insert into SITE_pcornet.diagnosis(
            diagnosisid,patid, encounterid, enc_type, admit_date, providerid, dx, dx_type, dx_date,
            dx_source, pdx, dx_origin, raw_dx, raw_dx_type, raw_dx_source, raw_pdx, dx_poa)
select cast(co.condition_occurrence_id as text) as diagnosisid,
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
	co.condition_start_date as dx_date,
	coalesce(m1.target_concept,'OT') as dx_source,
	coalesce(m2.target_concept, 'NI') as pdx,
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
	coalesce(m4.target_concept,'OT') as dx_poa
from SITE_pcornet.filter_diag co
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
	                                                                 m4.source_concept_class='dx_poa';
commit;



begin;
update SITE_pcornet.diagnosis
set dx = v.concept_code, 
dx_type = case when v.vocabulary_id = 'ICD9CM'  then '09'else
		case when  v.vocabulary_id in ('ICD10','ICD10CM')
		     then '10'
		     else 'OT' end end
from SITE_pcornet.diagnosis d
inner join SITE_pedsnet.condition_occurrence c on c.condition_occurrence_id = d.diagnosisid::int
inner join vocabulary.concept v on v.concept_code ilike trim(split_part(condition_source_value,'|',3)) and v.vocabulary_id in ('ICD10','ICD9CM','ICD10CM')
and trim(split_part(condition_source_value,'|',3)) ilike any (array['%B97.28%','%U07.1%','%B34.2%','%B34.9%','%B97.2%','%B97.21%','%J12.81%','%U04%','%U04.9%','%U07.2%','%Z20.828%'])
where d.dx_type in ('SM','OT') 
and SITE_pcornet.diagnosis.diagnosisid = d.diagnosisid 
and SITE_pcornet.diagnosis.dx_type in ('SM','OT');
commit;
