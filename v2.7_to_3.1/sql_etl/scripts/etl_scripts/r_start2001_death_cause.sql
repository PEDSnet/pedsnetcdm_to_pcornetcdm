begin;
Insert into SITE_3dot1_start2001_pcornet.death_cause(
	patid,
	death_cause, death_cause_code, death_cause_type,
	death_cause_source, death_cause_confidence, site
)
select
	patid,
	death_cause, death_cause_code, death_cause_type,
	death_cause_source, death_cause_confidence, site
	 from SITE_3dot1_pcornet.death_cause
where
	patid IN (select cast(person_id as text) from SITE_3dot1_start2001_pcornet.person_visit_start2001);
commit;