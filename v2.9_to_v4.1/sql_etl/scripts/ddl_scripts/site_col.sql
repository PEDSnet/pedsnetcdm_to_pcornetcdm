alter table stlouis_4dot0_pcornet.demographic add column site character varying not NULL;
alter table stlouis_4dot0_pcornet.enrollment add column site character varying not null;
alter table stlouis_4dot0_pcornet.death add column site character varying not null;
alter table stlouis_4dot0_pcornet.death_cause add column site character varying not null;
alter table stlouis_4dot0_pcornet.encounter add column site character varying not null;
alter table stlouis_4dot0_pcornet.condition add column site character varying not null;
alter table stlouis_4dot0_pcornet.diagnosis add column site character varying not null;
alter table stlouis_4dot0_pcornet.procedures add column site character varying not null;
alter table stlouis_4dot0_pcornet.dispensing   add column site character varying not null;
alter table stlouis_4dot0_pcornet.prescribing   add column site character varying not null;
alter table stlouis_4dot0_pcornet.vital   add column site character varying not null;
alter table stlouis_4dot0_pcornet.lab_result_cm   add column site character varying not null;
