-- condition_occurrence --> Diagnosis
-- Changes from previous version:
---- Drive dx_source from Observation.value_as_concept_id
---- Populate Pdx,raw_pdx, raw_dx_source

insert into dcc_pcornet.diagnosis(
            diagnosisid,patid, encounterid, enc_type, admit_date, providerid, dx, dx_type, 
            dx_source, pdx, raw_dx, raw_dx_type, raw_dx_source, raw_pdx,siteid)
select distinct 
	cast(co.condition_occurrence_id as text) as diagnosisid,
	cast(co.person_id as text) as patid,
	cast(co.visit_occurrence_id as text) encounterid,
	enc.enc_type,
	enc.admit_date,
	enc.providerid,
	case when condition_concept_id>0 then c1.concept_code
			else  case when site in('chop','nemours','stlouis') then split_part(condition_source_value,'|',2) 
			            else case when site = ('colorado') then split_part(condition_source_value,'|',1) 
					else  condition_source_value end end
		end as dx,
	case when condition_concept_id>0 then  'SM'
		else case 
			when c2.vocabulary_id = 'ICD9CM'  then '09' 
			else 
			case when  c2.vocabulary_id = 'ICD10' then '10' else 'OT' 
			end
		     end 
	end as dx_type,
	coalesce(m1.target_concept,'OT') as dx_source,
	case when enc_type in ('IP','IS') then coalesce(m2.target_concept,'OT') else case when enc_type in ('ED','AV','OA') then 'X' else NULL end end as pdx,
	condition_source_value as raw_dx,
	case when co.condition_source_concept_id = '44814649' then 'OT' else c3.vocabulary_id end as raw_dx_type,
        c4.concept_name as raw_dx_source,	
	case when co.condition_type_concept_id IN ('38000199','38000201') then c4.concept_name else NULL end as raw_pdx,
	site_id as siteid
from
	dcc_pedsnet.condition_occurrence co
	join dcc_pcornet.encounter enc on cast(co.visit_occurrence_id as text)=enc.encounterid
	join vocabulary.concept c1 on co.condition_concept_id = c1.concept_id  
	join vocabulary.concept c2 on co.condition_source_concept_id = c2.concept_id -- Join or LEFT JOIN — determine the source vocabulary
	left join dcc_pcornet.cz_omop_pcornet_concept_map m1 on m1.source_concept_class='dx_source' and cast(co.condition_type_concept_id as text) = m1.source_concept_id
	left join dcc_pcornet.cz_omop_pcornet_concept_map m2 on  cast(co.condition_type_concept_id as text) = m2.source_concept_id  and m2.source_concept_class='pdx'
	left join vocabulary.concept c3 on co.condition_source_concept_id = c3.concept_id
	left join vocabulary.concept c4 on co.condition_type_concept_id = c4.concept_id 
where co.condition_type_concept_id not in (38000245)

