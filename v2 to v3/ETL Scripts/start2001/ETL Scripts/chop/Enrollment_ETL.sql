

-- Observation_period -> Enrollment
-- Changes from previous version:
   -- default chart abstraction flag to yes, In PEDSnet we do not ask sites to provide this information to keep it simple

insert into chop_start2001_pcornet.enrollment (patid, enr_start_date, enr_end_date, chart, enr_basis, site)
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
	'E' as ENR_basis, 
	site as site
from
	chop_pedsnet.observation_period op
where
	op.person_id IN (select person_id from chop_start2001_pcornet.person_visit_start2001)
