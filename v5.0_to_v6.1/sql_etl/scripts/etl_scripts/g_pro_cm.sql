begin;

-- PHQ2 / PHQ9
insert into SITE_pcornet.pro_cm (
    pro_cm_id,
    encounterid,
    patid,
    pro_date,
    pro_time,
    pro_type,
    pro_item_loinc,
    pro_item_fullname,
    pro_measure_seq,
    pro_measure_score,
    pro_measure_loinc,
    pro_measure_fullname,
    pro_response_text,
    pro_response_num
)
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
        ) then question.concept_name
    end as pro_item_fullname,
    'PHQ' || person_id::varchar || coalesce(visit_occurrence_id::varchar,'') || date_part('year',observation_date)::text || LPAD(date_part('month',observation_date)::text,2,'0') || LPAD(date_part('day',observation_date)::text,2,'0') || LPAD(date_part('hour',observation_datetime)::text,2,'0') || LPAD(date_part('minute',observation_date)::text,2,'0') as pro_measure_seq,
    case
        when observation_concept_id in 
        (
            3042932, --PHQ2 score
            40758879 --PHQ9 score
        ) then value_as_number
    end as pro_measure_score,
    case
        when observation_concept_id in 
        (
            3042932, --PHQ2 score
            40758879 --PHQ9 score
        ) then answer.concept_code
    end as pro_measure_loinc,
    case
        when observation_concept_id in 
        (
            3042932, --PHQ2 score
            40758879 --PHQ9 score
        ) then question.concept_name
    end as pro_measure_fullname,
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
    end as pro_response_text,
    case
        when value_as_concept_id = 45883172 then 0 -- not at all
        when value_as_concept_id = 45879886 then 1 -- several days
        when value_as_concept_id = 45883172 then 2 -- more than half the days
        when value_as_concept_id = 45883172 then 3 -- nearly every day
    end as pro_response_num
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

begin;

-- Hunger Vital Signs
insert into SITE_pcornet.pro_cm (
    pro_cm_id,
    encounterid,
    patid,
    pro_date,
    pro_time,
    pro_type,
    pro_item_loinc,
    pro_item_fullname,
    pro_measure_seq,
    pro_measure_score,
    pro_measure_loinc,
    pro_measure_fullname,
    pro_response_text,
    pro_response_num
)
select 
    distinct on (observation_id)(observation_id)::text as pro_cm_id,
    obs.visit_occurrence_id::Varchar as encounterid,
    obs.person_id::varchar as patid,
    observation_date as pro_date,
    LPAD(date_part('hour',observation_datetime)::text,2,'0')||':'||LPAD(date_part('minute',observation_datetime)::text,2,'0') as pro_time,
    'LC' as pro_type,
    case    
        when observation_concept_id = 40192517 then '88122-7' -- LOINC equivalent for HVS1 that PCORnet Expects (We Use Snomed)
        when observation_concept_id = 40192426 then '88123-5' -- LOINC equivalent for HVS2 that PCORnet Expects (We Use Snomed)
    end as pro_item_loinc,
    case    
        when observation_concept_id = 40192517 then 'Within the past 12 months we worried whether our food would run out before we got money to buy more [U.S. Food Security Survey]'
        when observation_concept_id = 40192426 then 'Within the past 12 months the food we bought just didn''t last and we didn''t have money to get more [U.S. Food Security Survey]'
    end as pro_item_fullname,
    'HVS' || person_id::varchar || coalesce(visit_occurrence_id::varchar,'') || date_part('year',observation_date)::text || LPAD(date_part('month',observation_date)::text,2,'0') || LPAD(date_part('day',observation_date)::text,2,'0') || LPAD(date_part('hour',observation_datetime)::text,2,'0') || LPAD(date_part('minute',observation_date)::text,2,'0') as pro_measure_seq,
    null as pro_measure_score,
    case
        when observation_concept_id = 37116643 then '88124-3'
    end as pro_measure_loinc,
    case
        when observation_concept_id = 37116643 then 'Food insecurity risk (Hunger Vital Sign)'
    end as pro_measure_fullname,
    case    
        when observation_concept_id in 
            (
                40192517, -- Hunger Vital Sign 1
                40192426 -- Hunger Vital Sign 2
            ) 
            and 
            (
                value_as_concept_id = 4188539 
                or value_as_string in ('Often true','Sometimes true','Yes','YES')
            ) --yes
        then 'Sometimes true'
        when observation_concept_id in 
            (
                40192517, -- Hunger Vital Sign 1
                40192426 -- Hunger Vital Sign 2
            ) 
            and 
            (
                value_as_concept_id = 4188540 
                or value_as_string in ('Never true', 'No', 'NO')
            ) --no
        then 'Never true'
        when observation_concept_id in 
            (
                40192517, -- Hunger Vital Sign 1
                40192426 -- Hunger Vital Sign 2
            )  -- other
        then 'Don''t know or refused'
        when observation_concept_id = 37116643 and value_as_concept_id = 4188539 then 'At risk'
        when observation_concept_id = 37116643 and value_as_concept_id <> 4188539 then 'No Risk'
    end as pro_response_text,
    case
        when value_as_concept_id = 4188539 or value_as_string in ('Often true','Sometimes true','Yes','YES') then 1 -- at risk
        when value_as_concept_id = 4188540  or value_as_concept_id = 44814653 or value_as_string in ('Never true', 'No', 'NO') then 0 -- no risk
    end as pro_response_num
from 
    SITE_pedsnet.observation obs
inner join 
    SITE_pcornet.encounter enc 
    on cast(obs.visit_occurrence_id as text) = enc.encounterid
inner join 
    SITE_pcornet.demographic demo 
    on cast(obs.person_id as text) = demo.patid
where observation_concept_id in (
    40192517, -- Hunger Vital Sign 1
    40192426, -- Hunger Vital Sign 2
    37116643  -- General Food Insecurity Flag
)
;
commit;
