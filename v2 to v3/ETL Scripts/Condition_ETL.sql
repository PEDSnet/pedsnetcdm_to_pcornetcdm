
--set role pcor_et_user;

--drop table if exists pcornet_cdm.condition;

set search_path to pedsnet_cdm;

insert into pcornet_cdm.condition(
            conditionid, patid, encounterid, report_date, resolve_date, onset_date,
            condition_status, condition, condition_type, condition_source,
            raw_condition_status, raw_condition, raw_condition_type, raw_condition_source)
select distinct
	cast(co.condition_occurrence_id as text),
	cast(co.person_id as text) as patid,
	cast(co.visit_occurrence_id as text) as encounterid,
	--null as encounterid,
	co.condition_start_date as report_date,
	co.condition_end_date as resolve_date,
	cast (null as date) as onset_date, -- null for now,
	case when condition_end_date is null then 'AC' else 'RS' end as condition_status, -- Temp solution, need attention
	case when c1.concept_id = 0 then 'NM'||cast(round(random()*10000000000000) as text) else c1.concept_code end as condition,
	--c1.vocabulary_id as condition_type,
	COALESCE(cz.target_concept,'OT') as condition_type,
	'HC' as condition_source,
	null as raw_condition_status,
	co.condition_source_value as raw_condition,
	c2.vocabulary_id as raw_condition_type,
	null as raw_condition_source
from
	pedsnet_cdm.condition_occurrence co
	join pcornet_cdm.demographic d on d.patid = cast(co.person_id as text)
	left join pcornet_cdm.encounter e on e.encounterid = cast(co.visit_occurrence_id as text)
	join concept c1 on co.condition_concept_id = c1.concept_id
	join concept c2 on co.condition_source_concept_id = c2.concept_id
	left join pcornet_cdm.cz_omop_pcornet_concept_map cz on cz.source_concept_id= c1.vocabulary_id and source_concept_class ='condition type'
where
	co.condition_type_concept_id = '38000245' -- Problem list, not current condition (need to clarify)
