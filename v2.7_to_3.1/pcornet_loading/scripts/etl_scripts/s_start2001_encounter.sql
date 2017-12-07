begin;
insert into SITE_3dot1_start2001_pcornet.encounter (
            patid, encounterid, admit_date, admit_time, discharge_date, discharge_time,
            providerid, facility_location, enc_type, facilityid, discharge_disposition,
            discharge_status, drg, drg_type, admitting_source, raw_enc_type,
            raw_discharge_disposition, raw_discharge_status, raw_drg_type,
            raw_admitting_source,site)
select
	patid, encounterid, admit_date, admit_time, discharge_date, discharge_time,
            providerid, facility_location, enc_type, facilityid, discharge_disposition,
            discharge_status, drg, drg_type, admitting_source, raw_enc_type,
            raw_discharge_disposition, raw_discharge_status, raw_drg_type,
            raw_admitting_source,site from SITE_3dot1_pcornet.encounter
where
	encounterid IN (select cast(visit_id as text) from SITE_3dot1_start2001_pcornet.person_visit_start2001)
commit;