-- procedure_occurrence -> Procedures
-- Changes from previous version:
-- No longer need source coding system info. Use source_concept_id instead.
-- updated the table name to procedures
-- included the primary key field in the insertion value set

insert into dcc_3dot1_pcornet.procedures(
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
	-- case 2
	case when c.concept_id = 0 then
	---- case 2a
	case when m3.source_concept_id IS NOT NULL then split_part(procedure_source_value,'.',1)  
	---- case 2b
	else left(coalesce(po.procedure_source_value,'NM'||cast(round(random()*1000000000) as text)),11) end
	--case 1
	else left(c.concept_code,11) end as px,
	case when c.concept_id = 0 then 
		case when m3.source_concept_id IS NOT NULL then m3.target_concept 
	else 'OT' end 
	else coalesce(m1.target_concept,'OT') end as px_type,
	'OT' as px_source, -- tentative until we evolve PEDSnet CDM to capture this info
	split_part(procedure_source_value,'.',1) as raw_px,
	case when c2.vocabulary_id IS Null then 'Other' else c2.vocabulary_id end as raw_px_type,
	po.site as site
from
	dcc_pedsnet.procedure_occurrence po
	join dcc_3dot1_pcornet.encounter enc on cast(po.visit_occurrence_id as text)=enc.encounterid
	join vocabulary.concept c on po.procedure_concept_id=c.concept_id
	-- get the vocabulary from procedure concept id - to populate the PX_TYPE field (case 1)
	left join dcc_3dot1_pcornet.pedsnet_pcornet_valueset_map m1 on c.vocabulary_id = m1.source_concept_id AND m1.source_concept_class='Procedure Code Type'
	-- get the vocabulary for the RAW_PX_TYPE field - for all cases. 
	left join vocabulary.concept c2 on po.procedure_source_concept_id = c2.concept_id 
	-- get the vocabulary from the procedure source value to populate the PX_TYPE field (case 2a)
	left join dcc_3dot1_pcornet.pedsnet_pcornet_valueset_map m3 on c2.vocabulary_id = m3.source_concept_id AND m3.source_concept_class='Procedure Code Type';

