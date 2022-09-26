begin;
/* out of CDM ICD px codes */
delete from lurie_pcornet.procedures
where length(px) != 7  and px_type = '10';					
commit;

begin;
delete from lurie_pcornet.procedures
where length(px) < 5  and px_type = 'CH';					
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
	('vx_code_source','208','CX','724907','PFIZER COVID-19|78',''),
	('vx_code_source','208','CX','724907','SARS-COV-2 (PFIZER)',''),
	('vx_code_source','208','CX','724907','SARS-COV-2 (PFIZER)|319',''),
	('vx_code_source','207','CX','724907','MODERNA SARS-COV-2 VACCINE',''),
	('vx_code_source','207','CX','724907','MODERNA COVID-19',''),
	('vx_code_source','207','CX','724907','MODERNA COVID-19|71',''),
	('vx_code_source','207','CX','724907','SARS-COV-2 (MODERNA)',''),
	('vx_code_source','207','CX','724907','SARS-COV-2 (MODERNA)|318',''),
	('vx_code_source','207','CX','724907','MODERNA SARS-COV-2 VACCINATION',''),
	('vx_code_source','212','CX','702866','JANSSEN SARS-COV-2 VACCINE',''),
	('vx_code_source','212','CX','702866','JANSSEN (J&J) COVID-19',''),
	('vx_code_source','212','CX','702866','JANSSEN (J&J) COVID-19|86',''),
	('vx_code_source','212','CX','702866','SARS-COV-2 (JANSSEN)',''),
	('vx_code_source','212','CX','702866','SARS-COV-2 (JANSSEN)|321',''),
	('vx_code_source','213','CX','724904','COVID-19 VACCINE (NOT SPECIFIED)',''),
	('vx_code_source','213','CX','724904','COVID-19 VACCINE (NOT SPECIFIED)|79',''),
	('vx_code_source','213','CX','724904','SARS-COV-2, UNSPECIFIED','')
)
update lurie_pcornet.immunization
set vx_code = coalesce(target_concept,'999'),
vx_code_type = coalesce(pcornet_name, 'CX')
from lurie_pcornet.immunization imm
left join lurie_pedsnet.immunization dimm on dimm.lurie = 'lurie' and dimm.immunization_id = imm.immunizationid::int
left join vals on vals.concept_description ilike dimm.immunization_source_value
where imm.vx_code = ''
and imm.immunizationid = lurie_pcornet.immunization.immunizationid
and lurie_pcornet.immunization.vx_code = ''
and lurie_pcornet.immunization.vx_code = imm.vx_code;
commit;

begin;
/* updateing the NO mapps to UN */
update lurie_pcornet.obs_clin
set obsclin_result_modifier = 'UN'
where obsclin_result_modifier = 'NO';
commit;
begin;
/* updateing the NO mapps to UN */
update lurie_pcornet.obs_gen
set obsgen_result_modifier = 'UN'
where obsgen_result_modifier = 'NO';
commit;

/* removing tpn and bad values from med_admin if they aren't mapped to a "Tier 1" RxNorm class */ 
begin;
with tpn as (
	select
		medadminid
		from lurie_pcornet.med_admin n
	inner join 
		lurie_pedsnet.drug_exposure de 
		on n.medadminid::bigint = de.drug_exposure_id
	left join 
		vocabulary.concept v
		on n.medadmin_code = v.concept_code 
		and vocabulary_id = 'RxNorm'
	where
		(
			concept_class_id not in 
			('Clinical Drug', 'Branded Drug', 'Quant Clinical Drug', 
			'Quant Branded Drug', 'Clinical Pack', 'Branded Pack')	
			or concept_class_id is null
		)
		and drug_source_value ilike any
			(array[
			'%human milk%',
			'%breastmilk%',
			'%breast milk%',
			'%formula%',
			'%similac%',
			'%tpn%',
			'%parenteral nutrition%',
			'%fat emulsion%',
			'%UNDILUTED DILUENT%',
			'%KCAL/OZ%',
			'%kit%',
			'%item%',
			'%custom%',
			'%EMPTY BAG%'
			])
)
delete from lurie_pcornet.med_admin
where medadminid in (select medadminid from tpn);
commit;

/* removing tpn from prescribing */
begin;
with 
tpn as 
(select drug_exposure_id -- select count(*)
from lurie_pcornet.prescribing n
inner join lurie_pedsnet.drug_exposure de on n.prescribingid::int = de.drug_exposure_id
where rxnorm_cui is null and lower(drug_source_value) ilike any(array['%UNDILUTED DILUENT%','%KCAL/OZ%','%human milk%','%tpn%','%similac%','%fat emulsion%']))
delete from lurie_pcornet.prescribing
where prescribingid::int in (select drug_exposure_id from tpn);
commit;

/* removing TPN from dispensing */
begin;
with 
tpn as 
(select drug_exposure_id 
from lurie_pcornet.dispensing n
inner join lurie_pedsnet.drug_exposure de on n.dispensingid::int = de.drug_exposure_id
where lower(drug_source_value) ilike any(array['%UNDILUTED DILUENT%','%KCAL/OZ%','%human milk%','%tpn%','%similac%','%fat emulsion%']))
delete from lurie_pcornet.dispensing
where dispensingid::int in (select drug_exposure_id from tpn);
commit;

begin;
/* updating norm_modifier_low for the values */
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'EQ',
norm_modifier_high = 'EQ'
where result_modifier = 'EQ' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'GE',
norm_modifier_high = 'NO'
where result_modifier = 'GE' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'EQ',
norm_modifier_high = 'EQ'
where result_modifier = 'EQ' and norm_modifier_low = 'OT' and norm_modifier_high in ('GE','GT');
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'GE',
norm_modifier_high = 'NO'
where result_modifier = 'GE' and norm_modifier_low = 'OT' and norm_modifier_high = 'GE';
commit;
begin;
update lurie_pcornet.lab_result_cm
set result_modifier = 'GT',
norm_modifier_high = 'NO',
norm_modifier_low = 'GT'
where result_modifier = 'OT' and norm_modifier_low = 'OT' and norm_modifier_high = 'GT';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LT'
where result_modifier = 'LT' and norm_modifier_low = 'OT' and norm_modifier_high = 'GE';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'GT',
norm_modifier_high = 'NO'
where result_modifier = 'GT' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'GT',
norm_modifier_high = 'NO'
where result_modifier = 'GT' and norm_modifier_low in ('OT') and norm_modifier_high in ('GT','GE');
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LT'
where result_modifier = 'LT' and norm_modifier_low in ('OT') and norm_modifier_high in ('GT','GE');
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LE'
where result_modifier = 'LE' and norm_modifier_low in ('LT') and norm_modifier_high = 'OT';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LT'
where result_modifier = 'LT' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'OT'
where result_modifier = 'OT' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LE'
where result_modifier = 'LE' and norm_modifier_low in ('LT','LE') and norm_modifier_high = 'OT';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'GT',
norm_modifier_high = 'NO'
where result_modifier = 'GT' and norm_modifier_low = 'OT' and norm_modifier_high = 'GE';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'GT',
norm_modifier_high = 'NO',
result_modifier = 'GT'
where result_modifier = 'OT' and norm_modifier_low = 'OT' and norm_modifier_high = 'GE';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'EQ',
norm_modifier_high = 'EQ'
where result_modifier = 'EQ' and norm_modifier_low in ('OT') and norm_modifier_high = 'GT';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'GE',
norm_modifier_high = 'NO'
where result_modifier = 'GT' and norm_modifier_low in ('OT') and norm_modifier_high = 'GT';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_low = 'NO',
norm_modifier_high = 'LT'
where result_modifier = 'LT' and norm_modifier_low in ('OT') and norm_modifier_high = 'GT';
commit;
begin;
update lurie_pcornet.lab_result_cm
set norm_modifier_high = 'OT'
where result_modifier = 'OT' and norm_modifier_low in ('OT') and norm_modifier_high = 'GT';
commit;

/* ensure effective drug dosage number fits within numeric(15,8) for each of the corresponding fields in PCORnet */
begin;
update SITE_pcornet.prescribing
set rx_dose_ordered = trunc(rx_dose_ordered, (15 - length(split_part(rx_dose_ordered::text, '.', 1))))
from 
	SITE_pcornet.prescribing
where
	length(rx_dose_ordered::text) - 1 > 15
	and length(split_part(rx_dose_ordered::text, '.', 2)) > (15 - length(split_part(rx_dose_ordered::text, '.', 1)));
commit;

begin;
update SITE_pcornet.med_admin
set MEDADMIN_DOSE_ADMIN = trunc(MEDADMIN_DOSE_ADMIN, (15 - length(split_part(MEDADMIN_DOSE_ADMIN::text, '.', 1))))
from 
	SITE_pcornet.med_admin
where
	length(MEDADMIN_DOSE_ADMIN::text) - 1 > 15
	and length(split_part(MEDADMIN_DOSE_ADMIN::text, '.', 2)) > (15 - length(split_part(MEDADMIN_DOSE_ADMIN::text, '.', 1)));
commit;

begin;
update SITE_pcornet.dispensing
set DISPENSE_DOSE_DISP = trunc(DISPENSE_DOSE_DISP, (15 - length(split_part(DISPENSE_DOSE_DISP::text, '.', 1))))
from 
	SITE_pcornet.dispensing
where
	length(DISPENSE_DOSE_DISP::text) - 1 > 15
	and length(split_part(DISPENSE_DOSE_DISP::text, '.', 2)) > (15 - length(split_part(DISPENSE_DOSE_DISP::text, '.', 1)));
commit;
