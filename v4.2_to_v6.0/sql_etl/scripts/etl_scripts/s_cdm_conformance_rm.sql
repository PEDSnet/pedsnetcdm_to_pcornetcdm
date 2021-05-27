begin;
/* out of CDM ICD px codes */
delete from SITE_pcornet.procedures
where length(px) != 7  and px_type = '10';					
commit;

begin;
with vals (source_concept_class,target_concept,pcornet_name,source_concept_id,concept_description, value_as_concept_id) AS (VALUES
	('vx_code_source','48','CX','40213315','HIB (PRP-T)',''),
	('vx_code_source','171','CX','40213143','INFLUENZA, INJ., MDCK, PF, QUAD',''),
	('vx_code_source','185','CX','40213152','INFLUENZA, RECOMBINANT, QUADRIVALENT, PF',''),
	('vx_code_source','185','CX','40213152','INFLUENZA, QUADRIVALENT, PF, PEDIATRICS', ''),
	('vx_code_source','98','CX','40213237','PPD TEST',''),
	('vx_code_source','9','CX','40213228','TD (ADULT),2 LF TETANUS TOXOID,PRESERV VACCINE',''),
	('vx_code_source','115','CX','40213230','TDAP VACCINE',''),
	('vx_code_source','146','CX','40213284','DTAP/HEPB/IPV COMBINED VACCINE',''),
	('vx_code_source','49','CX','40213314','HIB (PRP-OMP)',''),
	('vx_code_source','15','CX','40213156','INFLUENZA SPLIT HIGH DOSE PF VACCINE',''),
	('vx_code_source','94','CX','40213184','MMR/VARICELLA COMBINED VACCINED',''),
	('vx_code_source','208','CX','724907','PR PFIZER SARS-COV-2 VACCINE',''),
	('vx_code_source','208','CX','724907','PFIZER SARS-COV-2 VACCINATION',''),
	('vx_code_source','208','CX','724907','COVID-19, MRNA, LNP-S, PF, 30 MCG/0.3 ML DOSE',''),
	('vx_code_source','208','CX','724907','PFIZER COVID-19',''),
	('vx_code_source','208','CX','724907','SARS-COV-2 (PFIZER)',''),
	('vx_code_source','207','CX','724907','MODERNA SARS-COV-2 VACCINE',''),
	('vx_code_source','207','CX','724907','MODERNA COVID-19',''),
	('vx_code_source','207','CX','724907','SARS-COV-2 (MODERNA)',''),
	('vx_code_source','207','CX','724907','MODERNA SARS-COV-2 VACCINATION',''),
	('vx_code_source','212','CX','702866','JANSSEN SARS-COV-2 VACCINE',''),
	('vx_code_source','212','CX','702866','JANSSEN (J&J) COVID-19',''),
	('vx_code_source','212','CX','702866','SARS-COV-2 (JANSSEN)',''),
	('vx_code_source','213','CX','724904','COVID-19 VACCINE (NOT SPECIFIED)','')
)
update SITE_pcornet.immunization
set vx_code = coalesce(target_concept,'999'),
vx_code_type = coalesce(pcornet_name, 'CX')
from SITE_pcornet.immunization imm
left join SITE_pedsnet.immunization dimm on dimm.site = 'SITE' and dimm.immunization_id = imm.immunizationid::int
left join vals on vals.concept_description ilike dimm.immunization_source_value
where imm.vx_code = ''
and imm.immunizationid = SITE_pcornet.immunization.immunizationid
and SITE_pcornet.immunization.vx_code = ''
and SITE_pcornet.immunization.vx_code = imm.vx_code;
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
