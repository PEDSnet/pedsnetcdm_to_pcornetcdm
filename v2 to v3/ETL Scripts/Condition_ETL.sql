
-- more changes likely to be made in the future based on Data Models issues 200 and 201
insert into dcc_pcornet.condition(
            conditionid, patid, encounterid, report_date, resolve_date, onset_date,
            condition_status, condition, condition_type, condition_source, 
            raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site)
select distinct
	cast(co.condition_occurrence_id as text),
	cast(co.person_id as text) as patid,
	cast(co.visit_occurrence_id as text) as encounterid,
	co.condition_start_date as report_date,
	co.condition_end_date as resolve_date,
	cast (null as date) as onset_date, -- null for now, being discussed in Data Models issue#200 
	case when condition_end_date is null then 'AC' else 'RS' end as condition_status, 
	case when c1.concept_id = 0 then 'NM'||cast(round(random()*10000000000000) as text) else c1.concept_code end as condition,
	COALESCE(cz.target_concept,'OT') as condition_type, 
	'HC' as condition_source,
	null as raw_condition_status, -- null for now, being discussed in Data Models issue#201
	co.condition_source_value as raw_condition,
	c2.vocabulary_id as raw_condition_type,
	null as raw_condition_source ,-- it is not discretely captured in the EHRs
	site as site
from
	dcc_pedsnet.condition_occurrence co
	join dcc_pcornet.demographic d on d.patid = cast(co.person_id as text)
	left join dcc_pcornet.encounter e on e.encounterid = cast(co.visit_occurrence_id as text)
	join vocabulary.concept c1 on co.condition_concept_id = c1.concept_id
	join vocabulary.concept c2 on co.condition_source_concept_id = c2.concept_id
	left join dcc_pcornet.cz_omop_pcornet_concept_map cz on cz.source_concept_id= c1.vocabulary_id and source_concept_class ='condition type'
where
	co.condition_type_concept_id = '38000245' -- Problem list only
