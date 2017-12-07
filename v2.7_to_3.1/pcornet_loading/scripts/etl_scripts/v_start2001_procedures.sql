begin;
insert into SITE_3dot1_start2001_pcornet.procedures(
            proceduresid,patid, encounterid, enc_type, admit_date, providerid, px_date,px, px_type, px_source,
            raw_px, raw_px_type,site)
select
	proceduresid,patid, encounterid, enc_type, admit_date, providerid, px_date,px, px_type, px_source,
            raw_px, raw_px_type,site from SITE_3dot1_pcornet.procedures
where
	 patid IN (select cast(person_id as text) from SITE_3dot1_start2001_pcornet.person_visit_start2001)
	 and EXTRACT(YEAR FROM px_date) >= 2001;



CREATE INDEX idx_proc_encid ON SITE_3dot1_start2001_pcornet.procedures (encounterid);

delete from SITE_3dot1_start2001_pcornet.procedures C
	where encounterid IS not NULL
	and encounterid in (select cast(visit_occurrence_id as text) from SITE_pedsnet.visit_occurrence where
					extract(year from visit_start_date)<2001);
commit;