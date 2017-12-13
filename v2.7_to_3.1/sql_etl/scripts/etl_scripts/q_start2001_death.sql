begin;
Insert into SITE_3dot1_start2001_pcornet.death(
	patid, death_date, death_date_impute,
	death_source, death_match_confidence, site
)
Select
	patid, death_date, death_date_impute,
	death_source, death_match_confidence, site
	 from SITE_3dot1_pcornet.death
Where
	patid IN (select cast(person_id as text) from SITE_3dot1_start2001_pcornet.person_visit_start2001);
commit;