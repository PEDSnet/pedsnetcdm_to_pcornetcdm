begin;
insert into SITE_3dot1_start2001_pcornet.enrollment (patid, enr_start_date, enr_end_date, chart, enr_basis, site)
select
	patid, enr_start_date, enr_end_date, chart, enr_basis, site
	 from SITE_3dot1_pcornet.enrollment
where
	patid IN (select cast(person_id as text) from SITE_3dot1_start2001_pcornet.person_visit_start2001);
commit;