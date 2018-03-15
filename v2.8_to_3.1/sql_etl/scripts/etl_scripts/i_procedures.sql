begin;

insert into SITE_pcornet.procedures(
            proceduresid,patid, encounterid, enc_type, admit_date, providerid, px_date,px, px_type, px_source,
            raw_px, raw_px_type,site)
select distinct
	cast(procedure_occurrence_id as text) as proceduresid,
	cast(person_id as text) as patid,
	cast(visit_occurrence_id as text) as encounterid,
	enc.enc_type as enc_type,
	enc.admit_date as admit_date,
	enc.providerid as providerid,
	procedure_date as px_date,
	case when c.concept_id = 0
	     then case when m3.source_concept_id IS NOT NULL
	               then split_part(procedure_source_value,'.',1)
	               else left(coalesce(po.procedure_source_value,'NM'||cast(round(random()*1000000000) as text)),11)
	          end
	     else left(c.concept_code,11)
	end as px,
	case when c.concept_id = 0
	     then case when m3.source_concept_id IS NOT NULL
	               then m3.target_concept
	               else 'OT'
	          end
	     else coalesce(m1.target_concept,'OT')
	end as px_type,
	coalesce(m4.target_concept,'OT') as px_source,
	split_part(procedure_source_value,'.',1) as raw_px,
	case when c2.vocabulary_id IS Null
	     then 'Other'
	     else c2.vocabulary_id
	     end as raw_px_type,
	po.site as site
from
	SITE_pedsnet.procedure_occurrence po
	join SITE_pcornet.encounter enc on cast(po.visit_occurrence_id as text)=enc.encounterid
	join vocabulary.concept c on po.procedure_concept_id=c.concept_id
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m1 on c.vocabulary_id = m1.source_concept_id AND
	                                                                m1.source_concept_class='Procedure Code Type'
	left join vocabulary.concept c2 on po.procedure_source_concept_id = c2.concept_id
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m3 on c2.vocabulary_id = m3.source_concept_id AND
	                                                                m3.source_concept_class='Procedure Code Type'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m4 on cast(po.procedure_type_concept_id as text) = m4.source_concept_id AND
	                                                                m4.source_concept_class='px source'
	where  person_id IN (select person_id from SITE_pcornet.person_visit_start2001)
	       and EXTRACT(YEAR FROM procedure_date) >= 2001
	       and visit_occurrence_id is not null
	       and visit_occurrence_id not in (select visit_occurrence_id from SITE_pedsnet.visit_occurrence where
					extract(year from visit_start_date)<2001);

commit;