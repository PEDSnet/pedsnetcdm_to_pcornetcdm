-- drug exposure --> Dispensing
-- join with demographic to make sure there are no orphan records 
-- more changes likely to be made based on Data Models #202
insert into dcc_3dot1_start2001_pcornet.dispensing(
            dispensingid, patid, prescribingid, 
            dispense_date, ndc, dispense_sup, dispense_amt, raw_ndc,site)
select
	* from dcc_3dot1_pcornet.dispensing

where	
	patid IN (select cast(person_id as text) from dcc_3dot1_start2001_pcornet.person_visit_start2001);
