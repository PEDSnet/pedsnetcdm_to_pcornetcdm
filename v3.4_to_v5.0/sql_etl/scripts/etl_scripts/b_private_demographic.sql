begin;

INSERT INTO SITE.private_demographic(
biobank_flag, birth_date, birth_time, gender_identity, hispanic, managing_org, mrn, org_patid,
	pat_firstname, pat_lastname, pat_maidenname, pat_middlename, pat_pref_language_spoken,
	pat_ssn, patid, primary_email, primary_phone, race, raw_gender_identity, raw_hispanic,
	raw_pat_name, raw_pat_pref_language_spoken, raw_race, raw_sex, raw_sexual_orientation, sex,
	sexual_orientation, site)
SELECT biobank_flag,
   birth_date,
   birth_time,
   gender_identity,
   hispanic,
   null as managing_org,
   null as mrn,
   null as org_patid,
   '' as pat_firstname, -- cannot be null
   '' as pat_lastname,  -- cannot be null
   null as pat_maidenname,
   null as pat_middlename,
   pat_pref_language_spoken,
   null as pat_ssn,
   patid,
   null as primary_email,
   null as primary_phone,
   race,
   raw_gender_identity,
   raw_hispanic,
   null as raw_pat_name,
   raw_pat_pref_language_spoken,
   raw_race,
   raw_sex,
   raw_sexual_orientation,
   sex,
   sexual_orientation,
   site
FROM SITE_pcornet.demographic;

commit;