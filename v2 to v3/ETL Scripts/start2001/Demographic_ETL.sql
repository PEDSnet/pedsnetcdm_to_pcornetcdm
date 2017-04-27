-- Person -> Demographic
-- Changes from previous version:
	-- defaulting the biobank flag to N

insert into dcc_start2001_pcornet.demographic (patid, birth_date, birth_time, sex, hispanic, race, biobank_flag, raw_sex, raw_hispanic, raw_race, site)
select
	* from dcc_pcornet.demographic
where
	patid IN (select cast(person_id as text) from dcc_start2001_pcornet.person_visit_start2001);


