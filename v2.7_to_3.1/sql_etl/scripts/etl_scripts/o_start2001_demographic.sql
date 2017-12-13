begin;
insert into SITE_3dot1_start2001_pcornet.demographic (patid, birth_date, birth_time, sex, hispanic, race, biobank_flag,
            raw_sex, raw_hispanic, raw_race, site)
select
	patid, birth_date, birth_time, sex, hispanic, race, biobank_flag, raw_sex, raw_hispanic, raw_race, site
	 from SITE_3dot1_pcornet.demographic
where
	patid IN (select cast(person_id as text) from SITE_3dot1_start2001_pcornet.person_visit_start2001);
commit;