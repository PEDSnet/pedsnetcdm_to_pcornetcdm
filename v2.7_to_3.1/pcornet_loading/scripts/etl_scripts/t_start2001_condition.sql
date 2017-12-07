begin;
insert into SITE_3dot1_start2001_pcornet.condition(
            conditionid, patid, encounterid, report_date, resolve_date, onset_date,
            condition_status, condition, condition_type, condition_source,
            raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site)
select conditionid, patid, encounterid, report_date, resolve_date, onset_date,
            condition_status, condition, condition_type, condition_source,
            raw_condition_status, raw_condition, raw_condition_type, raw_condition_source,site
            from
            SITE_3dot1_pcornet.condition
	 WHERE patid in (select cast(person_id as text) from SITE_3dot1_start2001_pcornet.person_visit_start2001 )
		AND
	 EXTRACT(YEAR FROM report_date)>=2001;

CREATE INDEX idx_cond_encid ON SITE_3dot1_start2001_pcornet.condition (encounterid);


delete from SITE_3dot1_start2001_pcornet.condition C
	where encounterid IS not NULL
	and encounterid in (select cast(visit_occurrence_id as text) from SITE_pedsnet.visit_occurrence V where
					extract(year from visit_start_date)<2001);
commit;