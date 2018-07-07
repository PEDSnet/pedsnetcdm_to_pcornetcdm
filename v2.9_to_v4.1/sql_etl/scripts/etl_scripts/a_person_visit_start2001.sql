begin;

CREATE TABLE SITE_pcornet.person_visit_start2001
AS
SELECT person_id, visit_occurrence_id AS visit_id
FROM SITE_pedsnet.visit_occurrence
WHERE EXTRACT(YEAR FROM visit_start_date) >= 2001;

ALTER TABLE SITE_pcornet.person_visit_start2001
ADD CONSTRAINT xpk_person_visit_start2001
PRIMARY KEY (visit_id);

-- Index: idx_pervis_personid

-- DROP INDEX stlouis_pcornet.idx_pervis_personid;

CREATE INDEX idx_SITE_personid
    ON stlouis_pcornet.person_visit_start2001 USING btree
    (person_id)
    TABLESPACE pg_default;

-- Index: idx_pervis_visitid

-- DROP INDEX stlouis_pcornet.idx_pervis_visitid;

CREATE INDEX idx_SITE_visitid
    ON stlouis_pcornet.person_visit_start2001 USING btree
    (visit_id)
    TABLESPACE pg_default;

commit;