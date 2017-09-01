
-- more changes likely to be made in the future based on Data Models issues 200 and 201
insert into dcc_3dot1_pcornet.condition(
            conditionid, patid, encounterid, report_date, resolve_date, onset_date,
            condition_status, condition, condition_type, condition_source, 
            raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site)
select distinct
	cast(co.condition_occurrence_id as text) as conditionid,
	cast(co.person_id as text) as patid,
	cast(co.visit_occurrence_id as text) as encounterid,
	co.condition_start_date as report_date,
	co.condition_end_date as resolve_date,
	cast (null as date) as onset_date, -- null for now, being discussed in Data Models issue#200 
	case when condition_end_date is null then 'AC' else 'RS' end as condition_status, 
	-- look for ICDs, followed by SNOMED, following by others
	case when c2.vocabulary_id in ('ICD9CM', 'ICD10','ICD10CM') 
		then 
		c2.concept_code
		else case when co.condition_concept_id>0
		 then c1.concept_code 
		 else trim(split_part(condition_source_value,'|',3))  end  end
	 as condition,
	case when c2.vocabulary_id = 'ICD9CM'  then '09' 
		else 
		case when  c2.vocabulary_id in ('ICD10','ICD10CM') then '10' else 
		case when co.condition_concept_id> 0 then 'SM' else 'OT' end  
		end 
	end  as condition_type, 
	'HC' as condition_source,
	condition_status_source_value as raw_condition_status,
	concat(split_part(condition_source_value,'|',1) as raw_condition, split_part(condition_source_value,'|',3)) as raw_condition,
	c2.vocabulary_id as raw_condition_type,
	null as raw_condition_source ,-- it is not discretely captured in the EHRs
	co.site as site
from
	dcc_pedsnet.condition_occurrence co
	join dcc_3dot1_pcornet.demographic d on d.patid = cast(co.person_id as text)
	left join dcc_3dot1_pcornet.encounter e on e.encounterid = cast(co.visit_occurrence_id as text)
	join vocabulary.concept c1 on co.condition_concept_id = c1.concept_id
	join vocabulary.concept c2 on co.condition_source_concept_id = c2.concept_id
	--left join dcc_3dot1_pcornet.cz_omop_pcornet_concept_map cz on cz.source_concept_id= c1.vocabulary_id and source_concept_class ='condition type'
where
	co.condition_type_concept_id in ( 2000000089, 2000000090, 2000000091)-- Problem list only
