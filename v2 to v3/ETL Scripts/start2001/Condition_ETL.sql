
-- more changes likely to be made in the future based on Data Models issues 200 and 201
insert into dcc_start2001_pcornet.condition(
            conditionid, patid, encounterid, report_date, resolve_date, onset_date,
            condition_status, condition, condition_type, condition_source, 
            raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site)
select * from dcc_pcornet.condition
where
	encounterid IN (select cast(visit_id as text) from dcc_start2001_pcornet.person_visit_start2001)
	and EXTRACT(YEAR FROM report_date)>=2001;

