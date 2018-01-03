begin;
ALTER TABLE SITE_3dot1_start2001_pcornet.vital ALTER original_bmi SET DATA TYPE NUMERIC(20,8);


insert into SITE_3dot1_start2001_pcornet.vital(
            vitalid, patid, encounterid, measure_date, measure_time, vital_source,
            ht, wt, diastolic, systolic, original_bmi, bp_position,
	    tobacco, tobacco_type, smoking
            ,raw_diastolic, raw_systolic, raw_bp_position,site)
select
	 vitalid, patid, encounterid, measure_date, measure_time, vital_source,
            ht, wt, diastolic, systolic, original_bmi, bp_position,
	    tobacco, tobacco_type, smoking
            ,raw_diastolic, raw_systolic, raw_bp_position,site from SITE_3dot1_pcornet.vital
where
	encounterid IN (select cast(visit_id as text) from SITE_3dot1_start2001_pcornet.person_visit_start2001) and
EXTRACT(YEAR FROM measure_date) >= 2001;
commit;