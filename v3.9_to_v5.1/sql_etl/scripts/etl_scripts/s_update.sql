begin;
update SITE_pcornet.lab_result_cm
set result_unit = '/100{WBCs}'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('/100 WBC','/100 WBC','/100 WBCS','/100(WBCs)','/100 wbc','/100WBC','/100wbc')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 's'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('second(s)','SECONDS','Seconds')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '/[HPF]'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('/HPF','/HPF','/hpf')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '/[LPF]'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('/LPF')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'mm/h'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('mm/hr','mm/hr','MM/HR','mm/Hr','MM/Hr','mm/1hr','mm/hr','mm/Hr','MM/HR')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'mg/(24.h)'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('mg/24hr','mg/day')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'g/(24.h)'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('g/day')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '%{vol}'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('vol %')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'Cel'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('CELSIUS')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '{cells}/uL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('cells/uL','cells/ul','cell/uL')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
 commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'mm[Hg]'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('mmHg')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '10*3/uL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('THOU/uL','Thousand/uL','THOU/ul','10 3/uL','th/uL','Thousands/uL','thousand/u;','Thou/uL','thou/uL','THOUS/MCL','thous/mcL','thousand/u;','Thousand/uL','thousand/ul','Thousands/uL')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = '10*6/uL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('10 6/uL','MIL/uL','mil/uL','MILL/MCL','mill/mcL','Mill/uL','mill/uL','Million/uL','million/ul','x10E6/uL')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm
set result_unit = 'ug/dL'
from SITE_pcornet.lab_result_cm l
inner join SITE_pedsnet.measurement m on m.measurement_id = l.lab_result_cm_id::int and m.unit_source_value in ('mcg/dL','MCG/DL','mcg/dl','mcg/dL (calc)')
where l.result_unit in ('NI','UN','OT','',null)
and SITE_pcornet.lab_result_cm.lab_result_cm_id = l.lab_result_cm_id;
commit;

begin;
update SITE_pcornet.lab_result_cm 
set result_modifier = 'EQ' 
where norm_modifier_high = 'EQ' and norm_modifier_low = 'OT' and result_modifier = 'OT'	;	
commit;

begin;
update SITE_pcornet.lab_result_cm 
set result_modifier = 'LE' 
where norm_modifier_high = 'LE' and norm_modifier_low = 'OT' and result_modifier in ('',null,'OT')	;
commit;

begin;
update SITE_pcornet.lab_result_cm 
set result_modifier = 'LT' 
where norm_modifier_high = 'LT' and norm_modifier_low = 'OT' and result_modifier = 'OT';		
commit;

begin;
update SITE_pcornet.lab_result_cm 
set result_modifier = 'EQ' 
where norm_modifier_high = 'OT' and norm_modifier_low = 'EQ' and result_modifier in ('',null,'OT');
commit;