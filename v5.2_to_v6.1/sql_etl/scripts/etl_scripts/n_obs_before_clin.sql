-- filter for valid records in pedsnet.observation table
begin;

Create table SITE_pcornet.filter_obs
as
select * 
from SITE_pedsnet.observation obs
where EXTRACT(YEAR FROM obs.observation_date)>=2001
and obs.person_id in (select person_id from SITE_pcornet.person_visit_start2001)
and (obs.visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001)
	 or obs.visit_occurrence_id is null);

commit;

-- get vitals from pedsnet.measurement that are not collected in pcornet.vitals
begin;

create table SITE_pcornet.meas_obsclin_loinc
as
select ('m'||meas.measurement_id)::text as obsclinid,
meas.person_id::text as patid,
meas.visit_occurrence_id::text as encounterid,
meas.provider_id::text as obsclin_providerid,
meas.measurement_date::date as obsclin_start_date,
coalesce(abn.target_concept, 'NI') as obsclin_abn_ind,
LPAD(date_part('hour',measurement_datetime)::text,2,'0')||':'||LPAD(date_part('minute',measurement_datetime)::text,2,'0') as obsclin_start_time,
case when measurement_concept_id = 4353936 then 'SM' else 'LC' end as obsclin_type,
case when meas.measurement_concept_id =4353936 then '250774007' else loinc.concept_code end as obsclin_code,
meas.value_source_value, meas.value_as_concept_id,
case when meas.measurement_concept_id =4353936 then '250774007' else null end as obsclin_result_snomed, 
meas.value_as_number::text as obsclin_result_text,
meas.operator_concept_id,
meas.unit_concept_id, meas.unit_source_value,
'HC' as obsclin_source,
null as raw_obsclin_name,
null as raw_obsclin_type,
null as raw_obsclin_code,
null as raw_obsclin_modifier,
meas.value_as_number::text as raw_obsclin_result,
meas.unit_concept_name as raw_obsclin_unit,
meas.site
from SITE_pedsnet.measurement meas 
left join vocabulary.concept loinc on loinc.concept_id = meas.measurement_concept_id and loinc.vocabulary_id = 'LOINC'
Left join pcornet_maps.pedsnet_pcornet_valueset_map abn on abn.source_concept_id::int = meas.value_as_concept_id and abn.source_concept_class = 'abnormal_indicator'
where meas.measurement_concept_id in (3020891, --Temperature
	3024171, -- Respiratory Rate
	40762499, --SpO2
	3027018, --Heart Rate
	4353936, -- FiO2
	21490852, --Invasive Mean arterial pressure (MAP)
	21492241, -- Non-Invasive Mean arterial pressure (MAP)
	3020158,--		See Note 1	FVC	
	3037879,--		See Note 1	FVC pre (if recorded differently)	
	3001668,--	See Note 1	FVC post	
	3024653,--	See Note 1	FEV 1	
	3005025,--	See Note 1	FEV 1 pre (if recorded differently)	
	3023550,--		See Note 1	FEV 1 post	
	42868460,--		See Note 1	FEF 25-75	
	42868461,--		See Note 1	FEF 25-75 pre (if recorded differently)	
	42868462,--		See Note 1	FEF 25-75 post	
	3023329); -- Peak Flow (PF) 

commit;

-- populate result_qual for above meas_obsclin_loinc records
begin;
create table SITE_pcornet.meas_obsclin_qual
as
select obsclinid,patid,encounterid,obsclin_providerid,obsclin_start_date,obsclin_start_time,obsclin_type,obsclin_code,
coalesce(
	map_qual.target_concept,
	case
            when lower(value_source_value) like '%1+%' then '1+'
            when lower(value_source_value) like '%2+%' then '2+'
            when lower(value_source_value) like '%3+%' then '3+'
            when lower(value_source_value) like '%a neg%' then 'A NEG'
            when lower(value_source_value) like '%a pos%' then 'A POS'
            when lower(value_source_value) like '%ab negative%' then 'AB NEG'
            when lower(value_source_value) like '%ab not detected%' then 'AB NOT DETECTED'
            when lower(value_source_value) like '%ab positive%' then 'AB POS'
            when lower(value_source_value) like '%abbnormal%' then 'ABNORMAL'
            when lower(value_source_value) like '%abnormal%' then 'ABNORMAL'
            when lower(value_source_value) like '%absent%' then 'ABSENT'
            when lower(value_source_value) like '%acanthocytes%' then 'ACANTHOCYTES'
            when lower(value_source_value) like '%adequate%' then 'ADEQUATE'
            when lower(value_source_value) like '%amber%' then 'AMBER'
            when lower(value_source_value) like '%amniotic fluid%' then 'AMNIOTIC FLUID'
            when lower(value_source_value) like '%anisocytosis%' then 'ANISOCYTOSIS'
            when lower(value_source_value) like '%arterial%' then 'ARTERIAL'
            when lower(value_source_value) like '%arterial line%' then 'ARTERIAL LINE'
            when lower(value_source_value) like '%b neg%' then 'B NEG'
            when lower(value_source_value) like '%b pos%' then 'B POS'
            when lower(value_source_value) like '%basophilic stippling%' then 'BASOPHILIC STIPPLING'
            when lower(value_source_value) like '%bite cells%' then 'BITE CELLS'
            when lower(value_source_value) like '%bizarre%' then 'BIZARRE CELLS'
            when lower(value_source_value) like '%black%' then 'BLACK'
            when lower(value_source_value) like '%blister cells%' then 'BLISTER CELLS'
            when lower(value_source_value) like '%blood%' then 'BLOOD'
            when lower(value_source_value) like '%bone marrow%' then 'BONE MARROW'
            when lower(value_source_value) like '%brown%' then 'BROWN'
            when lower(value_source_value) like '%burr cells%' then 'BURR CELLS'
            when lower(value_source_value) like '%cerebrospinal fluid%' then 'CEREBROSPINAL FLUID (CSF)'
            when lower(value_source_value) like '%clean catch%' then 'CLEAN CATCH'
            when lower(value_source_value) like '%Clear%' then 'CLEAR'
            when lower(value_source_value) like '%CLEAR%' then 'CLEAR'
            when lower(value_source_value) like '%clear%' then 'CLEAR'
            when lower(value_source_value) like '%cloudy%' then 'CLOUDY'
            when lower(value_source_value) like '%colorless%' then 'COLORLESS'
            when lower(value_source_value) like '%dacrocytes%' then 'DACROCYTES'
            when lower(value_source_value) like '%detected%' then 'DETECTED'
            when lower(value_source_value) like '%elliptocytes%' then 'ELLIPTOCYTES'
            when lower(value_source_value) like '%equivocal%' then 'EQUIVOCAL'
            when lower(value_source_value) like '%few%' then 'FEW'
            when lower(value_source_value) like '%green%' then 'GREEN'
            when lower(value_source_value) like '%hair%' then 'HAIR'
            when lower(value_source_value) like '%hazy%' then 'HAZY'
            when lower(value_source_value) like '%helmet%' then 'HELMET CELLS'
            when lower(value_source_value) like '%heterozygous%' then 'HETEROZYGOUS'
            when lower(value_source_value) like '%howelljolly%' then 'HOWELL-JOLLY BODIES'
            when lower(value_source_value) like '%howell jolly%' then 'HOWELL-JOLLY BODIES'
            when lower(value_source_value) like '%howell-jolly%' then 'HOWELL-JOLLY BODIES'
            when lower(value_source_value) like '%immune%' then 'IMMUNE'
            when lower(value_source_value) like '%Inconclusive%' then 'INCONCLUSIVE'
            when lower(value_source_value) like '%increased%' then 'INCREASED'
            when lower(value_source_value) like '%indeterminate%' then 'INDETERMINATE'
            when lower(value_source_value) like '%influenza A virus%' then 'INFLUENZA A VIRUS'
            when lower(value_source_value) like '%influenza B virus%' then 'INFLUENZA B VIRUS'
            when lower(value_source_value) like '%invalid%' then 'INVALID'
            when lower(value_source_value) like '%large%' then 'LARGE'
            when lower(value_source_value) like '%left arm%' then 'LEFT ARM'
            when lower(value_source_value) like '%low%' then 'LOW'
            when lower(value_source_value) like '%macrocytes%' then 'MACROCYTES'
            when lower(value_source_value) like '%many%' then 'MANY'
            when lower(value_source_value) like '%microcytes%' then 'MICROCYTES'
            when lower(value_source_value) like '%moderate%' then 'MODERATE'
            when lower(value_source_value) like '%nasopharyngeal%' then 'NASOPHARYNGEAL'
            when lower(value_source_value) like '%neg%' then 'NEGATIVE'
            when lower(value_source_value) like '%tnp%' then 'NI'
            when lower(value_source_value) like '%no growth%' then 'NO GROWTH'
            when lower(value_source_value) like '%none%' then 'NONE'
            when lower(value_source_value) like '%nonreactive%' then 'NONREACTIVE'
            when lower(value_source_value) like '%normal%' then 'NORMAL'
            when lower(value_source_value) like '%none detected.%' then 'NOT DETECTED'
            when lower(value_source_value) like '%not detected%' then 'NOT DETECTED'
            when lower(value_source_value) like '%o negative%' then 'O NEG'
            when lower(value_source_value) like '%o positive%' then 'O POS'
            when lower(value_source_value) like '%occasional%' then 'OCCASIONAL'
            when lower(value_source_value) like '%@%' then 'OT'
            when lower(value_source_value) like '%see Comment%' then 'OT'
            when lower(value_source_value) like '%ovalocytes%' then 'OVALOCYTES'
            when lower(value_source_value) like '%pappenheimer bodies%' then 'PAPPENHEIMER BODIES'
            when lower(value_source_value) like '%peritoneal fluid%' then 'PERITONEAL FLUID'
            when lower(value_source_value) like '%pink%' then 'PINK'
            when lower(value_source_value) like '%plasma%' then 'PLASMA'
            when lower(value_source_value) like '%pos%' then 'POSITIVE'
            when lower(value_source_value) like '%rare%' then 'RARE'
            when lower(value_source_value) like '%reactive%' then 'REACTIVE'
            when lower(value_source_value) like '%right arm%' then 'RIGHT ARM'
            when lower(value_source_value) like '%sars coronavirus 2%' then 'SARS CORONAVIRUS 2'
            when lower(value_source_value) like '%slight%' then 'SLIGHT'
            when lower(value_source_value) like '%Slightly Cloudy%' then 'SLIGHTLY CLOUDY'
            when lower(value_source_value) like '%small%' then 'SMALL'
            when lower(value_source_value) like '%Specimen unsatisfactory for evaluation%' then 'SPECIMEN UNSATISFACTORY FOR EVALUATION'
            when lower(value_source_value) like '%stomatocytes%' then 'STOMATOCYTES'
            when lower(value_source_value) like '%stool%' then 'STOOL'
            when lower(value_source_value) like '%straw%' then 'STRAW'
            when lower(value_source_value) like '%suspect%' then 'SUSPECTED'
            when lower(value_source_value) like '%synovial fluid%' then 'SYNOVIAL FLUID'
            when lower(value_source_value) like '%trace%' then 'TRACE'
            when lower(value_source_value) like '%turbid%' then 'TURBID'
            when lower(value_source_value) like '%unknown%' then 'UN'
            when lower(value_source_value) like '%undetected%' then 'UNDETECTABLE'
            when lower(value_source_value) like '%inconclusive%' then 'UNDETERMINED'
            when lower(value_source_value) like '%urine%' then 'URINE'
            when lower(value_source_value) like '%white%' then 'WHITE'
            when lower(value_source_value) like '%yellow%' then 'YELLOW'
	end,
	'OT') as obsclin_result_qual,
obsclin_abn_ind, meas.value_source_value,
obsclin_result_snomed, obsclin_result_text,
meas.operator_concept_id,
meas.unit_concept_id, meas.unit_source_value,obsclin_source,raw_obsclin_name,raw_obsclin_type,
raw_obsclin_code,raw_obsclin_modifier,raw_obsclin_result,raw_obsclin_unit,meas.site
from SITE_pcornet.meas_obsclin_loinc meas 
left join pcornet_maps.pedsnet_pcornet_valueset_map map_qual on cast(meas.value_as_concept_id as text)= map_qual.source_concept_id and map_qual.source_concept_class = 'Result qualifier'

commit;

begin;
drop table SITE_pcornet.meas_obsclin_loinc;
commit;

-- finalize records from meas_obsclin_loinc to insert into obs_clin
begin;

create table SITE_pcornet.meas_obsclin
as
select obsclinid,patid,encounterid,obsclin_providerid,obsclin_start_date,obsclin_start_time,obsclin_type,obsclin_code,
obsclin_result_qual,obsclin_result_snomed, obsclin_abn_ind, obsclin_result_text,null::date as obsclin_stop_date,null as obsclin_stop_time,
coalesce(map_mod.target_concept,'OT') as obsclin_result_modifier,
map.target_concept as obsclin_result_unit,
obsclin_source,raw_obsclin_name,raw_obsclin_type,
raw_obsclin_code,raw_obsclin_modifier,raw_obsclin_result,raw_obsclin_unit,meas.site
from SITE_pcornet.meas_obsclin_qual meas 
left join pcornet_maps.pedsnet_pcornet_valueset_map map on map.source_concept_id = meas.unit_concept_id::text and map.source_concept_class = 'Result unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map map_mod on map.source_concept_id = meas.operator_concept_id::text and map_mod.source_concept_class = 'Result modifier';

commit;

-- cleanup
begin;
drop table SITE_pcornet.meas_obsclin_qual;
commit;

begin;
delete from SITE_pcornet.meas_obsclin
where patid::int not in (select person_id from SITE_pcornet.person_visit_start2001);

delete from SITE_pcornet.meas_obsclin
where (encounterid is not null
and encounterid::int not in (select visit_id from SITE_pcornet.person_visit_start2001));
commit;

-- format filter_obs data (first query block in this file) to format for insertion to obs_clin table
begin;
create table SITE_pcornet.obs_vaping as
select ('o'||obs.observation_id)::text as obsclinid,
obs.person_id::text as patid,
obs.visit_occurrence_id::text as encounterid,
obs.provider_id::text as obsclin_providerid,
coalesce(abn.target_concept, 'NI') as obsclin_abn_ind,
obs.observation_date::date as obsclin_start_date,
LPAD(date_part('hour',obs.observation_datetime)::text,2,'0')||':'||LPAD(date_part('minute',obs.observation_datetime)::text,2,'0') as obsclin_start_time,
'SM' as obsclin_type,
snomed.concept_code as obsclin_code,
coalesce(qual.target_concept,'NI') as obsclin_result_qual,
snomed.concept_code as obsclin_result_snomed, --meas.value_as_number as obsclin_result_snomed,
obs.value_as_string::text as obsclin_result_text,
null as obsclin_result_modifier,
null as obsclin_result_unit,
'HC' as obsclin_source,
null as raw_obsclin_name,
null as raw_obsclin_type,
null as raw_obsclin_code,
null as raw_obsclin_modifier,
null as raw_obsclin_result,
null as raw_obsclin_unit,
null::date as obsclin_stop_date,
null as obsclin_stop_time,
obs.site
from SITE_pcornet.filter_obs obs
left join pcornet_maps.pedsnet_pcornet_valueset_map qual on qual.source_concept_id = obs.qualifier_concept_id::text and qual.source_concept_class in ('Result qualifier')
left join vocabulary.concept snomed on snomed.concept_id = obs.value_as_string::int and snomed.vocabulary_id = 'SNOMED'
Left join pcornet_maps.pedsnet_pcornet_valueset_map abn on abn.source_concept_id::int = obs.value_as_concept_id and abn.source_concept_class = 'abnormal_indicator'
where observation_concept_id = 4219336 and obs.value_as_concept_id in (42536422,42536421,36716478);
commit;

-- more cleanup
begin;
delete from SITE_pcornet.obs_vaping
where patid::int not in (select person_id from SITE_pcornet.person_visit_start2001);

delete from SITE_pcornet.obs_vaping
where (encounterid is not null
and encounterid::int not in (select visit_id from SITE_pcornet.person_visit_start2001));
commit;
