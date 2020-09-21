begin;
/* out of CDM ICD px codes */
delete from SITE_pcornet.procedures
where length(px) != 7  and px_type = '10';																	 
commit;
begin;
/* updateing the NO mapps to UN */
update SITE_pcornet.obs_clin
set obsclin_result_modifier = 'UN'
where obsclin_result_modifier = 'NO';
commit;
begin;
/* updateing the NO mapps to UN */
update SITE_pcornet.obs_gen
set obsgen_result_modifier = 'UN'
where obsgen_result_modifier = 'NO';
commit;
begin;
/* deleting the tpn, formulae and milk -- the code in ETL does not remove these values */ 
with 
tpn as 
(select drug_exposure_id  -- select count(*)
from SITE_pcornet.med_admin n
inner join SITE_pedsnet.drug_exposure de on n.medadminid::int = de.drug_exposure_id
where medadmin_code is null and lower(drug_source_value) ilike any(array['%UNDILUTED DILUENT%','%KCAL/OZ%','%human milk%','%tpn%','%similac%','%fat emulsion%']))
delete from SITE_pcornet.med_admin
where medadminid::int in (select drug_exposure_id from tpn);
commit;
begin;
/* removing tpn from prescribing */
with 
tpn as 
(select drug_exposure_id -- select count(*)
from SITE_pcornet.prescribing n
inner join SITE_pedsnet.drug_exposure de on n.prescribingid::int = de.drug_exposure_id
where rxnorm_cui is null and lower(drug_source_value) ilike any(array['%UNDILUTED DILUENT%','%KCAL/OZ%','%human milk%','%tpn%','%similac%','%fat emulsion%']))
delete from SITE_pcornet.prescribing
where prescribingid::int in (select drug_exposure_id from tpn);
commit;
begin;
/* removing TPN from dispensing */
with 
tpn as 
(select drug_exposure_id 
from SITE_pcornet.dispensing n
inner join SITE_pedsnet.drug_exposure de on n.dispensingid::int = de.drug_exposure_id
where lower(drug_source_value) ilike any(array['%UNDILUTED DILUENT%','%KCAL/OZ%','%human milk%','%tpn%','%similac%','%fat emulsion%']))
delete from SITE_pcornet.dispensing
where dispensingid::int in (select drug_exposure_id from tpn);
commit;
begin;
/* updating norm_modifier_low for the values */
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'EQ',
norm_modifier_high = 'EQ'
where result_modifier = 'EQ' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'GE',
norm_modifier_high = 'NO'
where result_modifier = 'GE' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'EQ',
norm_modifier_high = 'EQ'
where result_modifier = 'EQ' and norm_modifier_low = 'OT' and norm_modifier_high in ('GE','GT');
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'GE',
norm_modifier_high = 'NO'
where result_modifier = 'GE' and norm_modifier_low = 'OT' and norm_modifier_high = 'GE';
commit;
begin;
update SITE_pcornet.lab_result_cm
set result_modifier = 'GT',
norm_modifier_high = 'NO',
norm_modifier_low = 'GT'
where result_modifier = 'OT' and norm_modifier_low = 'OT' and norm_modifier_high = 'GT';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LT'
where result_modifier = 'LT' and norm_modifier_low = 'OT' and norm_modifier_high = 'GE';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'GT',
norm_modifier_high = 'NO'
where result_modifier = 'GT' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'GT',
norm_modifier_high = 'NO'
where result_modifier = 'GT' and norm_modifier_low in ('OT') and norm_modifier_high in ('GT','GE');
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LT'
where result_modifier = 'LT' and norm_modifier_low in ('OT') and norm_modifier_high in ('GT','GE');
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LE'
where result_modifier = 'LE' and norm_modifier_low in ('LT') and norm_modifier_high = 'OT';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LT'
where result_modifier = 'LT' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'OT'
where result_modifier = 'OT' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LE'
where result_modifier = 'LE' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'GT',
norm_modifier_high = 'NO'
where result_modifier = 'GT' and norm_modifier_low = 'OT' and norm_modifier_high = 'GE';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'GT',
norm_modifier_high = 'NO',
result_modifier = 'GT'
where result_modifier = 'OT' and norm_modifier_low = 'OT' and norm_modifier_high = 'GE';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'EQ',
norm_modifier_high = 'EQ'
where result_modifier = 'EQ' and norm_modifier_low in ('OT') and norm_modifier_high = 'GT';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'GE',
norm_modifier_high = 'NO'
where result_modifier = 'GT' and norm_modifier_low in ('OT') and norm_modifier_high = 'GT';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LT'
where result_modifier = 'LT' and norm_modifier_low in ('OT') and norm_modifier_high = 'GT';
commit;
begin;
update SITE_pcornet.lab_result_cm
set norm_modifier_high = 'OT'
where result_modifier = 'OT' and norm_modifier_low in ('OT') and norm_modifier_high = 'GT';
commit;