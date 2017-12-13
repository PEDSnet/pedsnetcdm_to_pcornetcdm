begin;
insert into SITE_3dot1_start2001_pcornet.dispensing(
            dispensingid, patid, prescribingid,
            dispense_date, ndc, dispense_sup, dispense_amt, raw_ndc,site)
select
	dispensingid, patid, prescribingid,
            dispense_date, ndc, dispense_sup, dispense_amt, raw_ndc,site from SITE_3dot1_pcornet.dispensing

where
	patid IN (select cast(person_id as text) from SITE_3dot1_start2001_pcornet.person_visit_start2001);
commit;