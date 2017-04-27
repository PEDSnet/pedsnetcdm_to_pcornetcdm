
-- Visit occurrence -> encounter
-- Observation_period -> Enrollment
-- Changes from previous version:
---- Change Concept ID for Residential Facility for Admitting source to 44814680'
---- Replace specific concept_id for No information/Unknown/Other with generic concept id
---- Change source column for raw_ target columns from value_as_concept_id to observation_source_value
---- changed the logic to extract DRGs (only MS-DRGs are needed by PCORnet)

insert into dcc_start2001_pcornet.encounter (
            patid, encounterid, admit_date, admit_time, discharge_date, discharge_time, 
            providerid, facility_location, enc_type, facilityid, discharge_disposition, 
            discharge_status, drg, drg_type, admitting_source, raw_enc_type, 
            raw_discharge_disposition, raw_discharge_status, raw_drg_type, 
            raw_admitting_source,site)
select
	* from dcc_pcornet.encounter
where
	encounterid IN (select cast(visit_id as text) from dcc_start2001_pcornet.person_visit_start2001)
