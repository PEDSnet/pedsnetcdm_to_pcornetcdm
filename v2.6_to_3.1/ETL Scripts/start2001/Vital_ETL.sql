---------- Vital query 
-- observation --> vital 
-- Changes from previous version:
---- Change source table from observation to measurement
---- Populate vital_source, raw vital source, raw diastolic and raw systolic
---- Use fact_relationship to tie diastolic BP and systolic PB
--- Not asked will be skipped and will be incorporated in the next ETL cycle since it is a meaningful use concept.(v2.1)
--- The query is agnostic to the concept id of the relationship.
-- We use a concatenated PK (based on ht, wt, dia, sys, bmi measurement ids

ALTER TABLE dcc_3dot1_start2001_pcornet.vital ALTER original_bmi SET DATA TYPE NUMERIC(20,8);


insert into dcc_3dot1_start2001_pcornet.vital(
            vitalid, patid, encounterid, measure_date, measure_time, vital_source, 
            ht, wt, diastolic, systolic, original_bmi, bp_position, 
	    tobacco, tobacco_type, smoking
            ,raw_diastolic, raw_systolic, raw_bp_position,site)
select
	 vitalid, patid, encounterid, measure_date, measure_time, vital_source, 
            ht, wt, diastolic, systolic, original_bmi, bp_position, 
	    tobacco, tobacco_type, smoking
            ,raw_diastolic, raw_systolic, raw_bp_position,site from dcc_3dot1_pcornet.vital
where
	encounterid IN (select cast(visit_id as text) from dcc_3dot1_start2001_pcornet.person_visit_start2001) and
EXTRACT(YEAR FROM measure_date) >= 2001;
