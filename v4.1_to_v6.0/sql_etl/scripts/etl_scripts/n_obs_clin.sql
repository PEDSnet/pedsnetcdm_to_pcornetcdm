begin;
INSERT INTO SITE_pcornet.obs_clin(encounterid, obsclin_code, obsclin_start_date, obsclin_providerid, obsclin_result_modifier, obsclin_result_snomed, obsclin_result_qual, obsclin_result_text, 
	obsclin_result_unit, obsclin_source, obsclin_start_time, obsclin_type, obsclin_abn_ind,obsclinid, patid, raw_obsclin_code, raw_obsclin_modifier, raw_obsclin_name, raw_obsclin_result, raw_obsclin_type, 
	raw_obsclin_unit, obsclin_stop_date, obsclin_stop_time,site)
select distinct on (obsclinid) encounterid, obsclin_code, obsclin_start_date, obsclin_providerid::text, obsclin_result_modifier, obsclin_result_snomed, obsclin_result_qual, obsclin_result_text::text, 
	obsclin_result_unit, obsclin_source, obsclin_start_time, obsclin_type, obsclin_abn_ind, obsclinid, patid, raw_obsclin_code, raw_obsclin_modifier, raw_obsclin_name, raw_obsclin_result::text, raw_obsclin_type, 
	raw_obsclin_unit,obsclin_stop_date, obsclin_stop_time, site 
from SITE_pcornet.meas_obsclin
union
select distinct on (obsclinid) encounterid, obsclin_code, obsclin_start_date, obsclin_providerid::text,obsclin_result_modifier, obsclin_result_snomed, obsclin_result_qual, obsclin_result_text::text, 
	obsclin_result_unit, obsclin_source, obsclin_start_time, obsclin_type, obsclin_abn_ind, obsclinid, patid, raw_obsclin_code, raw_obsclin_modifier, raw_obsclin_name, raw_obsclin_result::text, raw_obsclin_type, 
	raw_obsclin_unit,obsclin_stop_date, obsclin_stop_time, site 
from SITE_pcornet.obs_vaping;

commit;

/* vital data - ht, wt, systolic, diastolic, bmi, bp*/
begin;
INSERT INTO SITE_pcornet.obs_clin(encounterid, obsclin_code, obsclin_abn_ind, obsclin_start_date, obsclin_providerid, obsclin_result_modifier, obsclin_result_snomed, obsclin_result_qual, obsclin_result_text, 
	obsclin_result_unit, obsclin_source, obsclin_start_time, obsclin_type, obsclinid, patid, raw_obsclin_code, raw_obsclin_modifier, raw_obsclin_name, raw_obsclin_result, raw_obsclin_type, 
	raw_obsclin_unit, obsclin_stop_date, obsclin_stop_time,site)
select distinct on (obsclinid) ms.visit_occurrence_id::int as encounterid, 
coalesce(code.concept_code, null) as obsclin_code, 
coalesce(abn.target_concept, 'NI') as obsclin_abn_ind,
ms.measurement_date as obsclin_start_date, 
ms.provider_id as obsclin_providerid, 
coalesce(modif.target_concept,'NI') as obsclin_result_modifier, 
null as obsclin_result_snomed, 
coalesce(qual.target_concept,qual_src.target_concept,'NI') as obsclin_result_qual, 
ms.value_as_number::text as obsclin_result_text, 
coalesce(unit.target_concept, null) as obsclin_result_unit, 
'HC' as obsclin_source,
LPAD(date_part('hour',ms.measurement_datetime)::text,2,'0')||':'||LPAD(date_part('minute',ms.measurement_datetime)::text,2,'0') as obsclin_start_time,
'LC' as obsclin_type, 
('m'||measurement_id)::text as obsclinid, 
person_id::text as patid, 
coalesce(code.concept_code,'NI')  as raw_obsclin_code, 
null as raw_obsclin_modifier, 
code.concept_name as raw_obsclin_name, 
ms.value_as_number::text as raw_obsclin_result, 
code.vocabulary_id as raw_obsclin_type, 
ms.unit_source_value as raw_obsclin_unit, 
null::date as obsclin_stop_date, 
null as obsclin_stop_time,
ms.site as site
from SITE_pcornet.ms
left join vocabulary.concept code on code.concept_id = ms.measurement_concept_id and code.vocabulary_id = 'LOINC'
left join pcornet_maps.pedsnet_pcornet_valueset_map modif on modif.source_concept_id = ms.operator_concept_id::text and modif.source_concept_class = 'Result modifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map unit on unit.source_concept_id = ms.unit_concept_id::text and unit.source_concept_class in ('Dose unit','Result unit')
Left join pcornet_maps.pedsnet_pcornet_valueset_map abn on abn.source_concept_id::int = ms.value_as_concept_id and abn.source_concept_class = 'abnormal_indicator'
left join pcornet_maps.pedsnet_pcornet_valueset_map qual on cast(ms.value_as_concept_id as text)= qual.source_concept_id and qual.source_concept_class = 'Result qualifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map qual_src on lower(ms.value_source_value) ilike '%'|| qual_src.concept_description || '%' and qual_src.source_concept_class = 'result_qual_source';

commit;

/* vital data - tobacco*/
begin;
create table SITE_pcornet.tobacco_obclin as
select tobac.visit_occurrence_id::int as encounterid, 
coalesce(code.concept_code, null) as obsclin_code, 
coalesce(abn.target_concept, 'NI') as obsclin_abn_ind,
tobac.observation_date as obsclin_start_date, 
tobac.provider_id as obsclin_providerid, 
'NI' as obsclin_result_modifier, 
coalesce(code.concept_code, null) as obsclin_result_snomed, 
coalesce(qual.target_concept,qual_src.target_concept,'NI') as obsclin_result_qual, 
case when tobacco is not null and tobacco_type is not null then tobacco
     when smoking is not null and tobacco_type is not null then smoking 
end as obsclin_result_text, 
null as obsclin_result_unit, 
'HC' as obsclin_source,
LPAD(date_part('hour',tobac.observation_datetime)::text,2,'0')||':'||LPAD(date_part('minute',tobac.observation_datetime)::text,2,'0') as obsclin_start_time,
'SM' as obsclin_type, 
('o'||tobac.observation_id)::text as obsclinid, 
tobac.person_id::text as patid, 
coalesce(code.concept_code, null)  as raw_obsclin_code, 
null as raw_obsclin_modifier, 
code.concept_name as raw_obsclin_name, 
value_as_string as raw_obsclin_result, 
coalesce(code.vocabulary_id, null) as raw_obsclin_type, 
null as raw_obsclin_unit, 
null::date as obsclin_stop_date, 
null as obsclin_stop_time,
tobac.site as site
from SITE_pcornet.ob_tobacco_data tobac
left join vocabulary.concept code on code.concept_id = tobac.observation_concept_id and code.vocabulary_id = 'SNOMED'
left join pcornet_maps.pedsnet_pcornet_valueset_map qual on qual.source_concept_id = tobac.qualifier_concept_id::text and qual.source_concept_class in ('Result qualifier')
left join pcornet_maps.pedsnet_pcornet_valueset_map qual_src on lower(tobac.qualifier_source_value) ilike '%'|| qual_src.concept_description || '%' and qual_src.source_concept_class = 'result_qual_source'
Left join pcornet_maps.pedsnet_pcornet_valueset_map abn on abn.source_concept_id::int = tobac.value_as_concept_id and abn.source_concept_class = 'abnormal_indicator';

commit;

begin;
INSERT INTO SITE_pcornet.obs_clin( obsclinid,encounterid, obsclin_code, obsclin_abn_ind,obsclin_start_date, obsclin_providerid, obsclin_result_modifier, obsclin_result_snomed, obsclin_result_qual, obsclin_result_text, 
	obsclin_result_unit, obsclin_source, obsclin_start_time, obsclin_type, patid, raw_obsclin_code, raw_obsclin_modifier, raw_obsclin_name, raw_obsclin_result, raw_obsclin_type, 
	raw_obsclin_unit, obsclin_stop_date, obsclin_stop_time,site)
select distinct on (obsclinid) obsclinid, encounterid, obsclin_code, obsclin_abn_ind,obsclin_start_date, obsclin_providerid, obsclin_result_modifier, obsclin_result_snomed, obsclin_result_qual, obsclin_result_text, 
	obsclin_result_unit, obsclin_source, obsclin_start_time, obsclin_type, patid, raw_obsclin_code, raw_obsclin_modifier, raw_obsclin_name, raw_obsclin_result, raw_obsclin_type, 
	raw_obsclin_unit, obsclin_stop_date, obsclin_stop_time,site
from SITE_pcornet.tobacco_obclin;

commit;

begin;
delete from SITE_pcornet.obs_clin
where patid::int not in (select person_id from SITE_pcornet.person_visit_start2001);

delete from SITE_pcornet.obs_clin
where (encounterid is not null
and encounterid::int not in (select visit_id from SITE_pcornet.person_visit_start2001));

commit;

begin;
update SITE_pcornet.obs_clin
set obsclin_result_modifier = 'UN'
where obsclin_result_modifier = 'NO';
commit;

begin;

drop table if exists SITE_pcornet.meas_obsclin;
drop table if exists SITE_pcornet.obs_vaping;
drop table if exists SITE_pcornet.tobacco_obclin;
commit;
