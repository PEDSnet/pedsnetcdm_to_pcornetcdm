

-- Observation_period -> Enrollment
-- Changes from previous version:
   -- default chart abstraction flag to yes, In PEDSnet we do not ask sites to provide this information to keep it simple

--set role pcor_et_user;

--drop table if exists pcornet_cdm.enrollment;

set search_path to pedsnet_cdm;

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
	'Y' as chart, -- defaulting to yes
	'E' as ENR_basis
from
	pedsnet_cdm.observation_period op
