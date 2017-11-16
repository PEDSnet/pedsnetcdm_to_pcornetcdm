begin;
insert into SITE_3dot1_start2001_pcornet.diagnosis(
            diagnosisid,patid, encounterid, enc_type, admit_date, providerid, dx, dx_type,
            dx_source, pdx, raw_dx, raw_dx_type, raw_dx_source, raw_pdx,site)
select
	 diagnosisid,patid, encounterid, enc_type, admit_date, providerid, dx, dx_type,
            dx_source, pdx, raw_dx, raw_dx_type, raw_dx_source, raw_pdx,site from SITE_3dot1_pcornet.diagnosis
where
	encounterid IN (select CAST(visit_id as TEXT) from SITE_3dot1_start2001_pcornet.person_visit_start2001)
	 and encounterid in
	 (select cast(visit_occurrence_id as text) from SITE_pedsnet.condition_occurrence where extract (year from condition_start_date)
		>=2001)
delete from SITE_3dot1_start2001_pcornet.diagnosis C
where length(dx) < 2;
commit;