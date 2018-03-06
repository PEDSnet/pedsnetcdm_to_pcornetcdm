begin;

create table if not exists SITE_pcornet.procedure_occurrence
as
select procedure_occurrence_id, person_id, visit_occurrence_id, procedure_date, procedure_concept_id, 
       procedure_source_concept_id, procedure_type_concept_id, procedure_source_value,site
from SITE_pedsnet.procedure_occurrence
where visit_occurrence_id is not null and
      person_id in (select person_id  from SITE_pcornet.person_visit_start2001) and
      visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001);
      
create table if not exists SITE_pcornet.procedures
as
select distinct
	procedure_occurrence_id::varchar(256) as proceduresid,
	person_id::varchar(2566) as patid,
	visit_occurrence_id::varchar(256) as encounterid,
	enc.enc_type as enc_type,
	enc.admit_date as admit_date,
	enc.providerid as providerid,
	procedure_date as px_date,
	(case when c.concept_id = 0
	     then case when m3.source_concept_id IS NOT NULL
	               then split_part(procedure_source_value,'.',1)
	               else left(coalesce(po.procedure_source_value,'NM'||cast(round(random()*1000000000) as text)),11)
	          end
	     else left(c.concept_code,11)
	end)::varchar(11) as px,
	(case when c.concept_id = 0
	     then case when m3.source_concept_id IS NOT NULL
	               then m3.target_concept
	               else 'OT'
	          end
	     else coalesce(m1.target_concept,'OT')
	end)::varchar(2) as px_type,
	coalesce(m4.target_concept,'OT')::varchar(2) as px_source,
	split_part(procedure_source_value,'.',1)::varchar(256) as raw_px,
	(case when c2.vocabulary_id IS Null
	     then 'Other'
	     else c2.vocabulary_id
	 end)::varchar(256) as raw_px_type,
	po.site as site
from
	SITE_pcornet.procedure_occurrence po
	join SITE_pcornet.encounter enc on visit_occurrence_id::varchar(256)=enc.encounterid
	join vocabulary.concept c on po.procedure_concept_id=c.concept_id
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m1 on c.vocabulary_id = m1.source_concept_id AND
	                                                                m1.source_concept_class='Procedure Code Type'
	left join vocabulary.concept c2 on po.procedure_source_concept_id = c2.concept_id
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m3 on c2.vocabulary_id = m3.source_concept_id AND
	                                                                m3.source_concept_class='Procedure Code Type'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m4 on cast(po.procedure_type_concept_id as text) = m4.source_concept_id AND
	                                                                m4.source_concept_class='px source';
                                                                    
drop table if exists SITE_pcornet.procedure_occurrence;

commit;