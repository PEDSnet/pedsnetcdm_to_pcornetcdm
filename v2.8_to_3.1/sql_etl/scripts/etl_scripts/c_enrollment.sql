
-- filter site_pedsnet table for the observation_period
/*
create table if not exists SITE_pcornet.observation_period
as
select person_id, observation_period_start_date, observation_period_end_date, 'Y'::varchar(1) as chart, 'E'::varchar(1) as enr_basis, site
from SITE_pedsnet.observation_period
where person_id in (select person_id from SITE_pcornet.person_visit_start2001);
*/

-- formatt the observation table for creating the pcornet enrollment table.
create table if not exists SITE_pcornet.enrollment
as
select distinct
	cast(person_id as text) as patid,
	cast(
	cast(date_part('year', observation_period_start_date) as text)||'-'||lpad(cast(date_part('month', observation_period_start_date) as text),2,'0')||'-'||lpad(cast(date_part('day', observation_period_start_date) as text),2,'0')
	as date)
	as enr_start_date,
	cast( cast(date_part('year', observation_period_end_date) as text)||'-'||lpad(cast(date_part('month', observation_period_end_date) as text),2,'0')||'-'||lpad(cast(date_part('day', observation_period_end_date) as text),2,'0')
	as date)
	as enr_end_date,
	'Y'::varchar(1) as chart, -- defaulting to yes
	'E'::varchar(1) as enr_basis,
	site::varchar(32) as site
from
	SITE_pedsnet.observation_period
where person_id in (select person_id from SITE_pcornet.person_visit_start2001);
    
-- delete the observation_period table
-- drop table if exists SITE_pcornet.observation_period;