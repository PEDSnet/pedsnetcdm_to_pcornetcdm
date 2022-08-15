begin;

insert into SITE_pcornet.procedures(
            proceduresid,patid, encounterid, enc_type, admit_date, providerid, px_date,px, px_type, px_source,
            ppx, raw_ppx,
            raw_px, raw_px_type,site)
select distinct
	cast(procedure_occurrence_id as text) as proceduresid,
	cast(person_id as text) as patid,
	cast(visit_occurrence_id as text) as encounterid,
	enc.enc_type as enc_type,
	enc.admit_date as admit_date,
	enc.providerid as providerid,
	procedure_date as px_date,
	coalesce(
		px_cd_1.concept_code, 
		px_cd_2.concept_code, 
		case 
			when left(split_part(procedure_source_value,'|',2),11) = ' ' 
			or left(split_part(procedure_source_value,'|',2),11) = '' then 'NI'
			else LTRIM(left(split_part(procedure_source_value,'|',2),11))
		end) as px,
    coalesce(px_typ.target_concept,'OT')as px_type,
	coalesce(m4.target_concept,'OT') as px_source,
	coalesce(m5.target_concept,'OT') as ppx,
	split_part(procedure_source_value,'|',1) as raw_px,
	coalesce(px_cd_1.vocabulary_id,px_cd_2.vocabulary_id,'OT') as raw_px_type,
	procedure_type_concept_id as raw_ppx, 
	'SITE' as site
from SITE_pedsnet.procedure_occurrence po
	join SITE_pcornet.encounter enc on cast(po.visit_occurrence_id as text)=enc.encounterid
	left join vocabulary.concept px_cd_1 on px_cd_1.concept_id = po.procedure_concept_id and px_cd_1.vocabulary_id in ('HCPCS','CPT4','ICD10PCS','ICD9Proc')
    left join vocabulary.concept px_cd_2 on px_cd_2.concept_id = po.procedure_source_concept_id and px_cd_2.vocabulary_id in ('HCPCS','CPT4','ICD10PCS','ICD9Proc')
	left join pcornet_maps.pedsnet_pcornet_valueset_map px_typ 
 		on case 
			when px_cd_1.vocabulary_id is not null then px_cd_1.vocabulary_id
	  		else px_cd_2.vocabulary_id 
		end = px_typ.source_concept_id 
 		and source_concept_class = 'Procedure Code Type'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m4 on cast(po.procedure_type_concept_id as text) = m4.source_concept_id AND
	                                                                m4.source_concept_class='px source'
	left join pcornet_maps.pedsnet_pcornet_valueset_map m5 on cast(po.procedure_type_concept_id as text) = m5.source_concept_id AND
	                                                                m5.source_concept_class='ppx'                                                                
	where  person_id IN (select person_id from SITE_pcornet.person_visit_start2001)
	       and EXTRACT(YEAR FROM procedure_date) >= 2001
	       and visit_occurrence_id is not null
	       and visit_occurrence_id not in (select visit_occurrence_id from SITE_pedsnet.visit_occurrence where
					extract(year from visit_start_date)<2001)
	       and po.procedure_concept_id not in (select concept_id from vocabulary.concept where concept_class_id in ('CPT4 Modifier','2-dig nonbill code'))
	       and po.procedure_source_concept_id not in (select concept_id from vocabulary.concept where concept_class_id in ('CPT4 Modifier','2-dig nonbill code'));


-- insert covid 19 immunization records into procedures table
insert into SITE_pcornet.procedures(
            proceduresid,patid, encounterid, enc_type, admit_date, providerid, px_date,px, px_type, px_source,
            ppx, raw_ppx,
            raw_px, raw_px_type,site)
select
	distinct on (immunization_id)('i'||immunization_id)::text as proceduresid,
	cast(person_id as text) as patid,
	cast(visit_occurrence_id as text) as encounterid,
	enc.enc_type as enc_type,
	enc.admit_date as admit_date,
	enc.providerid as providerid,
	immunization_date as px_date,
	case 
		when immunization_concept_id=724907 then 91300 -- PFIZER
		when immunization_concept_id=724906 then 91301  -- MODERNA
		when immunization_concept_id=702866 then 91303 -- JANSSEN
		end as px,
    'CH' as px_type,
	'DR' as px_source,
	'OT' as ppx,
	split_part(immunization_source_value,'|',1) as raw_px,
	'CVX' as raw_px_type,
	immunization_type_concept_id as raw_ppx, 
	'SITE' as site
from SITE_pedsnet.immunization imm
	inner join SITE_pcornet.encounter enc on cast(imm.visit_occurrence_id as text)=enc.encounterid                                                           
	where  
		immunization_concept_id in (
		724907, -- PFIZER
		724906, -- MODERNA
		702866 -- JANSSEN
		)
		and person_id IN (select person_id from SITE_pcornet.person_visit_start2001)
	       and EXTRACT(YEAR FROM immunization_date) >= 2001
	       and (visit_occurrence_id not in (select visit_occurrence_id from SITE_pedsnet.visit_occurrence where
					extract(year from visit_start_date)<2001) or visit_occurrence_id is null);

commit;
