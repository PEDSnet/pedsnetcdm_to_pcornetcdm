

-- Observation_period -> Enrollment
-- Changes from previous version:
-- Change these two rows from Biobank flag mappings

-- N|Chart availability|4001345|44814650|No information
-- N|Chart availability|4001345|44814653|Unknown

-- Reason: Use generic concept ID for No information and Unknown.

insert into pcornet_cdm.enrollment (patid, enr_start_date, enr_end_date, chart, enr_basis)
select distinct 
	cast(op.person_id as text) as pat_id,
	cast(
	cast(date_part('year', observation_period_start_date) as text)||'-'||lpad(cast(date_part('month', observation_period_start_date) as text),2,'0')||'-'||lpad(cast(date_part('day', observation_period_start_date) as text),2,'0') 
	as date)
	as enr_start_date,
	cast( cast(date_part('year', observation_period_end_date) as text)||'-'||lpad(cast(date_part('month', observation_period_end_date) as text),2,'0')||'-'||lpad(cast(date_part('day', observation_period_end_date) as text),2,'0') 
	as date) 
	as enr_end_date,
	case when o.person_id is null then 'N' else coalesce(m1.target_concept,'N') end as chart,
	'E' as ENR_basis
from
	observation_period op
	left join observation o on op.person_id = o.person_id and observation_concept_id = 4030450
	left join pcornet_cdm.cz_omop_pcornet_concept_map m1 on case when o.value_as_concept_id is null AND m1.value_as_concept_id is null then true else o.value_as_concept_id = m1.value_as_concept_id end and m1.source_concept_class = 'Chart availability'

