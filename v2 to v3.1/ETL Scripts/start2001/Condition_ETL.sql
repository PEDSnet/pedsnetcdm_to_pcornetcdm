
-- more changes likely to be made in the future based on Data Models issues 200 and 201
insert into dcc_3dot1_start2001_pcornet.condition(
            conditionid, patid, encounterid, report_date, resolve_date, onset_date,
            condition_status, condition, condition_type, condition_source, 
            raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site)
select conditionid, patid, encounterid, report_date, resolve_date, onset_date,
            condition_status, condition, condition_type, condition_source, 
            raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site from dcc_3dot1_pcornet.condition
where 
	patid in (Select cast(person_id as text) from dcc_start2001_pcornet.person_visit_start2001)
	and EXTRACT(YEAR FROM report_date)>=2001;

