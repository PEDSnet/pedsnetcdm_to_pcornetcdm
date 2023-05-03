begin;

-- PHQ2 / PHQ9
insert into SITE_pcornet.pro_cm(
    pro_cm_id,
    encounterid,
    patid,
    pro_date,
    pro_time,
    pro_type,
    pro_item_loinc,
    pro_response_text,
    pro_measure_seq,
    pro_measure_score,
    pro_measure_loinc,
    pro_item_fullname,
    pro_measure_fullname
select 
    distinct on (observation_id)(observation_id)::text as pro_cm_id,
    obs.visit_occurrence_id::Varchar as encounterid,
    obs.person_id::varchar as patid,
    observation_date as pro_date,
    LPAD(date_part('hour',observation_datetime)::text,2,'0')||':'||LPAD(date_part('minute',observation_datetime)::text,2,'0') as pro_time,
    'LC' as pro_type,
    case    
        when observation_concept_id in 
        (
            3042924, --PHQ 1
            3045858, --PHQ 2
            3045933, --PHQ 3
            3044964, --PHQ 4
            3044098, --PHQ 5
            3043801, --PHQ 6
            3045019, --PHQ 7
            3043785, --PHQ 8
            3043462  --PHQ 9
        ) then question.concept_code
        else null
    end as pro_item_loinc,
    case    
        when observation_concept_id in 
        (
            3042924, --PHQ 1
            3045858, --PHQ 2
            3045933, --PHQ 3
            3044964, --PHQ 4
            3044098, --PHQ 5
            3043801, --PHQ 6
            3045019, --PHQ 7
            3043785, --PHQ 8
            3043462  --PHQ 9
        ) then answer.concept_name
        else null
    end as pro_response_text,
    person_id::varchar 
        || coalesce(visit_occurrence_id::varchar,'')
        || date_part('year',observation_date)::text
        || LPAD(date_part('month',observation_date)::text,2,'0')
        || LPAD(date_part('day',observation_date)::text,2,'0')
        || LPAD(date_part('hour',observation_datetime)::text,2,'0')
        || LPAD(date_part('minute',observation_date)::text,2,'0')
    as pro_measure_seq,
    case
        when observation_concept_id in 
        (
            3042932, --PHQ2 score
            40758879 --PHQ9 score
        ) then value_as_number
        else null
    end as pro_measure_score,
    case
        when observation_concept_id in 
        (
            3042932, --PHQ2 score
            40758879 --PHQ9 score
        ) then answer.concept_code
        else null
    end as pro_measure_loinc,
    case    
        when observation_concept_id in 
        (
            3042924, --PHQ 1
            3045858, --PHQ 2
            3045933, --PHQ 3
            3044964, --PHQ 4
            3044098, --PHQ 5
            3043801, --PHQ 6
            3045019, --PHQ 7
            3043785, --PHQ 8
            3043462  --PHQ 9
        ) then question.concept_name
        else null
    end as pro_item_fullname,
    case
        when observation_concept_id in 
        (
            3042932, --PHQ2 score
            40758879 --PHQ9 score
        ) then question.concept_name
        else null
    end as pro_measure_fullname
from 
    SITE_pedsnet.observation obs
inner join 
    SITE_pcornet.encounter enc 
    on cast(obs.visit_occurrence_id as text) = enc.encounterid
inner join 
    SITE_pcornet.demographic demo 
    on cast(obs.person_id as text) = demo.patid
left join 
    vocabulary.concept question 
    on obs.observation_concept_id = question.concept_id
left join
    vocabulary.concept answer
    on obs.value_as_concept_id = answer.concept_id
where observation_concept_id in (
    3042924, --PHQ 1
    3045858, --PHQ 2
    3045933, --PHQ 3
    3044964, --PHQ 4
    3044098, --PHQ 5
    3043801, --PHQ 6
    3045019, --PHQ 7
    3043785, --PHQ 8
    3043462, --PHQ 9
    3042932, --PHQ2 score
    40758879 --PHQ9 score
)
;
commit;
