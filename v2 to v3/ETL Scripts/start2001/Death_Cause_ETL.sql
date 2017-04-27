Insert into dcc_start2001_pcornet.death_cause(
	patid,
	death_cause, death_cause_code, death_cause_type,
	death_cause_source, death_cause_confidence, site
)
select 
	* from dcc_pcornet.death_cause 
where
	patid IN (select cast(person_id as text) from dcc_start2001_pcornet.person_visit_start2001)
