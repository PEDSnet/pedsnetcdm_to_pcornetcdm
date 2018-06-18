begin;

CREATE TABLE SITE_pcornet.person_visit_start2001
AS
SELECT person_id, visit_occurrence_id AS visit_id
FROM SITE_pedsnet.visit_occurrence
WHERE EXTRACT(YEAR FROM visit_start_date) >= 2001;

ALTER TABLE SITE_pcornet.person_visit_start2001
ADD CONSTRAINT xpk_person_visit_start2001
PRIMARY KEY (visit_id);

commit;