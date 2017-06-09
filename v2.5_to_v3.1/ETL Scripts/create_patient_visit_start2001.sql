-- Create table of patients and visits occuring in or after 2001
-- Use:
	-- for restricting CHOP pedsnetcdm_to_pcornetcdm ETL transforms
CREATE TABLE dcc_3dot1_start2001_pcornet.person_visit_start2001 
AS
SELECT person_id, visit_occurrence_id AS visit_id
FROM dcc_pedsnet.visit_occurrence
WHERE EXTRACT(YEAR FROM visit_start_date) >= 2001;

ALTER TABLE dcc_3dot1_start2001_pcornet.person_visit_start2001
ADD CONSTRAINT xpk_person_visit_start2001
PRIMARY KEY (visit_id);

CREATE INDEX idx_person_id
ON dcc_3dot1_start2001_pcornet.person_visit_start2001 (person_id);
