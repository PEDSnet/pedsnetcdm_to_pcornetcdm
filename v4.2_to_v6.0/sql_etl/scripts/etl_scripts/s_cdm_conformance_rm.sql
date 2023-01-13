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
