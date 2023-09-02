begin;
update SITE_pcornet.lab_result_cm
set result_unit = target_concept
from SITE_pcornet.lab_result_cm l
left join pcornet_maps.pedsnet_pcornet_valueset_map map on lower(map.target_concept) = lower(l.raw_unit) and source_concept_class in ('result_unit_source','Result unit')
where l.result_unit in ('','OT','NI') 
and SITE_pcornet.lab_result_cm.result_unit in ('','OT','NI') 
and l.lab_result_cm_id = SITE_pcornet.lab_result_cm.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '/100{WBCs}'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('/100 WBC','/100 WBCS','/100(WBCs)','/100 wbc','/100WBC','/100wbc')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 's'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('second(s)','SECONDS','Seconds')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '/[HPF]'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('/HPF','/hpf')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '/[LPF]'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('/LPF')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'mm/h'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('mm/hr','MM/HR','mm/Hr','MM/Hr','mm/1hr')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'mg/(24.h)'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('mg/24hr','mg/day')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'g/(24.h)'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('g/day')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '%{vol}'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('vol %')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'Cel'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('CELSIUS')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '{cells}/uL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('cells/uL','cells/ul','cell/uL')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
 commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'mm[Hg]'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('mmHg','mmHG','mmHG.')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '10*3/uL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('THOU/uL','Thousand/uL','THOU/ul','10 3/uL','th/uL','Thousands/uL','thousand/u;','Thou/uL','thou/uL','THOUS/MCL','thous/mcL','thousand/u;','Thousand/uL','thousand/ul','Thousands/uL', 'K/mm3','k/mm3')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '10*6/uL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('10 6/uL','MIL/uL','mil/uL','MILL/MCL','mill/mcL','Mill/uL','mill/uL','Million/uL','million/ul','x10E6/uL','M/mm3','m/mm3')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'ug/dL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('mcg/dL','MCG/DL','mcg/dl','mcg/dL (calc)')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'mg/dL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('mg/dL')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '%'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('%')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '/mm3'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('/mm3')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '10*-3.eq/L'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('mEq/L')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'fL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('fL')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'g/dL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('g/dL')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '[IU]/L'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('IU/L')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'pg'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('pg')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'ng/mL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('ng/mL')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'mmol/L'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::bigint and m.unit_source_value in ('mmol/L')
where (l.result_unit in ('NI','UN','OT','') or l.result_unit is null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm 
set result_unit = '[pH]'
where 
    (
    lab_loinc in ('11558-4','2749-0','5803-2','2746-6')
    or raw_lab_name ilike any(
    array[
        '%pH of Venous blood%',
        '%pH of Blood%',
        '%pH of Urine by Test strip%',
        '%pH of Blood%',
        '%pH of Urine by Test strip%',
        '%pH of Gastric fluid%',
        '%pH of Capillary blood%',
        '%pH of Venous blood%',
        '%pH of Urine by Test strip%'
        ])
    )
and result_unit in ('OT','','NI','UN');
commit;

begin;
update SITE_pcornet.lab_result_cm 
set result_unit = '{ratio}'
where 
    (
    lab_loinc in ('5811-5','1759-0','2965-2','6301-6')
    or raw_lab_name ilike any(
    array[
        '%INR in Platelet poor plasma by Coagulation assay%',
        '%Specific gravity of Urine%',
        '%Specific gravity of Urine by Test strip%',
        '%Albumin/Globulin [Mass Ratio] in Serum or Plasma%'
        ])
    )
and result_unit in ('OT','','NI','UN');
commit;

begin;
update SITE_pcornet.lab_result_cm 
set result_unit = '{#}'
where 
    (
    lab_loinc in ('11282-1')
    or raw_lab_name ilike any(
    array[
        '%Cells Counted Total [#] in Blood%'
        ])
    )
and result_unit in ('OT','','NI','UN');
commit;

-- DC 2.06 for Seattle
begin;
update SITE_pcornet.lab_result_cm 
set 
	result_num = result_num / 1000,
	result_unit = '10*3/uL'
where
	lab_loinc = '26499-4'
	and result_unit in ('/mm3','/uL');
commit;

-- DC 2.06 for CHOP --> BASOPHILS ABSOLUTE
begin;
update SITE_pcornet.lab_result_cm 
set 
	result_num = result_num / 1000,
	result_unit = '10*3/uL'
where
	lab_loinc = '704-7'
	and result_unit in ('uL','/uL','{#}/uL','{cells}/uL');
commit;

-- DC 2.06 for CHOP --> LYMPHOCYTES ABSOLUTE
begin;
update SITE_pcornet.lab_result_cm 
set 
	result_num = result_num / 1000,
	result_unit = '10*3/uL'
where
	lab_loinc = '731-0'
	and result_unit in ('uL','/uL','{#}/uL','{cells}/uL');
commit;

-- DC 2.06 for CHOP --> MONOCYTES ABSOLUTE
begin;
update SITE_pcornet.lab_result_cm 
set 
	result_num = result_num / 1000,
	result_unit = '10*3/uL'
where
	lab_loinc in ('743-5','742-7')
	and result_unit in ('uL','/uL','{#}/uL','{cells}/uL');
commit;

-- DC 2.06 for CHOP --> NEUTROPHILS ABSOLUTE
begin;
update SITE_pcornet.lab_result_cm 
set 
	result_num = result_num / 1000,
	result_unit = '10*3/uL'
where
	lab_loinc in ('26499-4','751-8')
	and result_unit in ('uL','/uL','{#}/uL','{cells}/uL');
commit;

begin;
update SITE_pcornet.lab_result_cm 
set result_modifier = 'EQ' 
where norm_modifier_high = 'EQ' and norm_modifier_low = 'OT' and result_modifier = 'OT';	
commit;

begin;
update SITE_pcornet.lab_result_cm 
set result_modifier = 'LE' 
where norm_modifier_high = 'LE' and norm_modifier_low = 'OT' and (result_modifier in ('','OT') or result_modifier is null);
commit;

begin;
update SITE_pcornet.lab_result_cm 
set result_modifier = 'LT' 
where norm_modifier_high = 'LT' and norm_modifier_low = 'OT' and result_modifier = 'OT';		
commit;

begin;
update SITE_pcornet.lab_result_cm 
set result_modifier = 'EQ' 
where norm_modifier_high = 'OT' and norm_modifier_low = 'EQ' and (result_modifier in ('','OT') or result_modifier is null);
commit;

begin;
update SITE_pcornet.lab_result_cm 
set  
    norm_modifier_low = 'NO',
    norm_modifier_high = 'LT'
where 
    result_modifier = 'EQ'
    and norm_modifier_high = 'EQ' 
    and norm_modifier_low = 'EQ' 
    and norm_range_low is null
    and norm_range_high is not null;
commit;

begin;
update SITE_pcornet.lab_result_cm 
set  
    result_modifier = 'EQ',
    norm_modifier_low = 'EQ',
    norm_modifier_high = 'EQ'
where 
    result_modifier = 'LT'
    and norm_modifier_low = 'NO' 
    and norm_modifier_high = 'LT' 
    and norm_range_low is not null
    and norm_range_high is not null;
commit;

-- solution to DC 3.06
-- flips 1 diagosis on an encounter to primary if no primaries exist (stratified by enc_type and dx_origin)
-- dx_orign = OD, enc_type = IP
begin;
-- get distribution of the number of primary and secondary OD diagnoses for each IP encounter
with primary_diagnosis_distribution as (
select 
	encounterid, 
	enc_type,
	dx_origin,
	sum(case when pdx = 'P' then 1 else 0 end) as prim,
	sum(case when pdx <> 'P' then 1 else 0 end) as sec
from 
	SITE_pcornet.diagnosis
where
	enc_type = 'IP'
	and dx_origin = 'OD'
group by 
	encounterid, 
	enc_type,
	dx_origin
),

-- get all encounters with 0 primary diagnoses
no_primary_diagnoses as (
select 
    *
from primary_diagnosis_distribution where prim = 0
),

-- define row numbers for each secondary diagnosis
secondary_diagnosisids as (
select 
	encounterid,
	diagnosisid,
	ROW_NUMBER() OVER (PARTITION BY encounterid order by diagnosisid) as rn
from 
	SITE_pcornet.diagnosis
where 
	encounterid in (select encounterid from no_primary_diagnoses)
	and enc_type = 'IP'
	and dx_origin = 'OD'
),

-- get 1 secondary diagnosis for each encounter
scondary_to_primary_candidate as (
select diagnosisid
from secondary_diagnosisids
where rn = 1
)

-- update that secondary diagnosis as primary
update SITE_pcornet.diagnosis
set pdx = 'P'
where diagnosisid in (select diagnosisid from scondary_to_primary_candidate);

commit;

-- dx_orign = OD, enc_type = EI
begin;
-- get distribution of the number of primary and secondary OD diagnoses for each IP encounter
with primary_diagnosis_distribution as (
select 
	encounterid, 
	enc_type,
	dx_origin,
	sum(case when pdx = 'P' then 1 else 0 end) as prim,
	sum(case when pdx <> 'P' then 1 else 0 end) as sec
from 
	SITE_pcornet.diagnosis
where
	enc_type = 'EI'
	and dx_origin = 'OD'
group by 
	encounterid, 
	enc_type,
	dx_origin
),

-- get all encounters with 0 primary diagnoses
no_primary_diagnoses as (
select 
    *
from primary_diagnosis_distribution where prim = 0
),

-- define row numbers for each secondary diagnosis
secondary_diagnosisids as (
select 
	encounterid,
	diagnosisid,
	ROW_NUMBER() OVER (PARTITION BY encounterid order by diagnosisid) as rn
from 
	SITE_pcornet.diagnosis
where 
	encounterid in (select encounterid from no_primary_diagnoses)
	and enc_type = 'EI'
	and dx_origin = 'OD'
),

-- get 1 secondary diagnosis for each encounter
scondary_to_primary_candidate as (
select diagnosisid
from secondary_diagnosisids
where rn = 1
)

-- update that secondary diagnosis as primary
update SITE_pcornet.diagnosis
set pdx = 'P'
where diagnosisid in (select diagnosisid from scondary_to_primary_candidate);

commit;

-- update for Stanford DC 3.13 - White Blood Cell LOINC codes
begin;
update SITE_pcornet.lab_result_cm
set lab_loinc = '26464-8'
where lab_loinc = '20584-9' and specimen_source = 'BLD';
commit;
