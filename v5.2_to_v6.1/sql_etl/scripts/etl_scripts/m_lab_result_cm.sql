begin;
with filter_lab as
(select measurement_id, specimen_source_value
 from SITE_pcornet.specimen_values
 where specimen_source = 'OT' or specimen_source is null
)
update SITE_pcornet.specimen_values 
set specimen_source = coalesce(s.target_concept, 'OT')
from filter_lab m
inner join pcornet_maps.pedsnet_pcornet_valueset_map s on trim(lower(split_part(m.specimen_source_value,'|',1))) = s.source_concept_id and s.source_concept_class = 'specimen_source'
where m.measurement_id = SITE_pcornet.specimen_values.measurement_id and SITE_pcornet.specimen_values.specimen_source = 'OT' or SITE_pcornet.specimen_values.specimen_source is null;
commit;

begin;
drop table SITE_pcornet.lab_measurements;
commit;

begin;
create table SITE_pcornet.lab_priority_modif
as
select distinct on (m.measurement_id) m.measurement_id as lab_result_cm_id,
	cast(m.person_id as text) as patid,
	cast(m.visit_occurrence_id as text) as encounterid,
	specimen_source,
	'OD' as lab_result_source,
	'LM' as lab_loinc_source,
	lab_loinc,
	priority.target_concept as priority,
	case when m.measurement_source_value like 'POC%'
	     then 'P'
	     else 'L'
	     end as result_loc,
	null as lab_px,
	null as lab_px_type,
	m.measurement_order_date as lab_order_date,
	m.measurement_date as specimen_date,
	date_part('hour',m.measurement_datetime)||':'||date_part('minute',m.measurement_datetime) as specimen_time,
	coalesce(m.measurement_result_date, m.measurement_date) as result_date,
	LPAD(date_part('hour',m.measurement_result_datetime)::text,2,'0')||':'||LPAD(date_part('minute',m.measurement_result_datetime)::text,2,'0') as result_time,
	m.value_as_concept_id, value_source_value,
	null as result_snomed, 
	m.value_as_number as result_num,
	coalesce(
        case 
            when m.operator_concept_id is not null and m.operator_concept_id <> 0 then rslt_modif.target_concept 
        end, 
        case 
            when trim(split_part(m.modifier, '|', 1)) in ('EQ','GE','GT') then trim(split_part(m.modifier, '|', 1)) 
            when trim(split_part(m.modifier, '|', 2)) in ('EQ','LE','LT') then trim(split_part(m.modifier, '|', 2)) 
        end,
        case 
            when m.value_as_number is not null then 'EQ' 
        end,
		rslt_modif.target_concept
    ) as result_modifier,
	m.unit_concept_id,
	left(m.range_low::text,10) as norm_range_low,
    coalesce(case when rslt_modif.target_concept = 'EQ' then 'EQ' when rslt_modif.target_concept in ('GE','GT') then rslt_modif.target_concept when rslt_modif.target_concept in ('LE','LT') then 'NO' end,
			 trim(split_part(m.modifier, '|', 1))) as norm_modifier_low,
	left(m.range_high::text,10) as norm_range_high,
    coalesce(case when rslt_modif.target_concept = 'EQ' then 'EQ' when rslt_modif.target_concept in ('GE','GT') then 'NO' when rslt_modif.target_concept in ('LE','LT') then rslt_modif.target_concept end,
			 trim(split_part(m.modifier, '|', 2)))  as norm_modifier_high,
	null as abn_ind, -- null for now until new conventions evolve
	raw_lab_name,
	raw_lab_code,
	null as raw_panel,
	c2.concept_name || m.value_as_number::text as raw_result,
	m.unit_source_value,
	null as raw_order_dept,
	null as raw_facility_code,
	'SITE' as site
from SITE_pcornet.specimen_values m
left join vocabulary.concept c2 on m.operator_concept_id = c2.concept_id and  c2.domain_id = 'Meas Value Operator'
left join pcornet_maps.pedsnet_pcornet_valueset_map rslt_modif on cast(m.operator_concept_id as text) = rslt_modif.source_concept_id and rslt_modif.source_concept_class = 'Result modifier'
left join pcornet_maps.pedsnet_pcornet_valueset_map priority on cast(m.priority_concept_id as text)= priority.source_concept_id and priority.source_concept_class = 'Lab priority';

commit;

begin;
drop table SITE_pcornet.specimen_values;
commit;

begin;
create table SITE_pcornet.lab_unit as
select lab_result_cm_id,patid,encounterid,specimen_source,lab_result_source,lab_loinc_source,
	lab_loinc,priority,result_loc,lab_px,lab_px_type,lab_order_date,specimen_date,specimen_time,
	result_date,result_time,m.value_as_concept_id, value_source_value, result_snomed, result_num,
	result_modifier,
	coalesce(units.target_concept, unit_src.target_concept) as result_unit,
	norm_range_low,
    norm_modifier_low,
	norm_range_high,
    norm_modifier_high,
	abn_ind, -- null for now until new conventions evolve
	raw_lab_name,
	raw_lab_code,
	raw_panel,
	raw_result,
	m.unit_source_value as raw_unit,
	raw_order_dept,
	raw_facility_code,
	site
from SITE_pcornet.lab_priority_modif m
left join pcornet_maps.pedsnet_pcornet_valueset_map units on cast(m.unit_concept_id as text)= units.source_concept_id and units.source_concept_class = 'Result unit'
left join pcornet_maps.pedsnet_pcornet_valueset_map unit_src on trim(m.unit_source_value)= unit_src.source_concept_id and unit_src.source_concept_class = 'result_unit_source';

commit;

begin;
drop table SITE_pcornet.lab_priority_modif;
commit;

begin;
CREATE INDEX idx_labms_valcptid
    ON SITE_pcornet.lab_unit USING btree
    (value_as_concept_id)
    TABLESPACE pg_default;
commit;

begin;
CREATE INDEX idx_labms_valsrcid
    ON SITE_pcornet.lab_unit USING btree
    (value_source_value)
    TABLESPACE pg_default;
commit;

begin;
create table SITE_pcornet.lab_qual as
select lab_result_cm_id,patid,encounterid,specimen_source,lab_result_source,lab_loinc_source,lab_loinc,
	priority,result_loc,lab_px,lab_px_type,lab_order_date,specimen_date,specimen_time,result_date,result_time,
	coalesce(
		qual.target_concept,
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
	'OT') as result_qual, 
	value_source_value,
	result_snomed, result_num,result_modifier,result_unit,norm_range_low,norm_modifier_low,norm_range_high,
    norm_modifier_high,abn_ind, raw_lab_name,raw_lab_code,raw_panel,raw_result,raw_unit,raw_order_dept,raw_facility_code,site
from SITE_pcornet.lab_unit m
left join pcornet_maps.pedsnet_pcornet_valueset_map qual on cast(m.value_as_concept_id as text)= qual.source_concept_id and qual.source_concept_class = 'Result qualifier';
commit;

begin;
drop table SITE_pcornet.lab_unit;
commit;
