

-- Observation_period -> Enrollment
-- Changes from previous version:
   -- default chart abstraction flag to yes, In PEDSnet we do not ask sites to provide this information to keep it simple

insert into dcc_3dot1_start2001_pcornet.enrollment (patid, enr_start_date, enr_end_date, chart, enr_basis, site)
select
	* from dcc_3dot1_pcornet.enrollment
where
	patid IN (select cast(person_id as text) from dcc_3dot1_start2001_pcornet.person_visit_start2001);
