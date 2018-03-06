begin;

create table if not exists SITE_pcornet.lab_result_cm
as
select
	m.measurement_id::varchar(256) as lab_result_cm_id,
	m.person_id::varchar(256) as patid,
	m.visit_occurrence_id::varchar(256) as encounterid,
	coalesce( m1.target_concept,'OT')::varchar(10) as lab_name,
	--m2.target_concept as specimen_source,
	(case when lower(specimen_source_value) like '%blood%'
		then 'BLOOD'
		else case when lower(specimen_source_value) like '%csf%'
		          then 'CSF'
		          else case when lower(specimen_source_value) like '%plasma%'
		                    then 'PLASMA'
		                    else case when lower(specimen_source_value) like '%serum%'
		                              then 'SERUM'
		                              else case when lower(specimen_source_value) like '%urine%'
		                                        then 'URINE'
		                                        else case when specimen_source_value is not null
		                                                  then 'OT'
		                                                  else 'NI'
		                                        end
		                              end
		                    end
		          end
		end
    end)::varchar(10) as specimen_source,
	c1.concept_code::varchar(10) as lab_loinc,
	m7.target_concept::varchar(2) as priority,
	(case when measurement_source_value like 'POC%'
	     then 'P'
	     else 'L'
	 end)::varchar(2) as result_loc,
	null::varchar(11) as lab_px,
	null::varchar(2) as lab_px_type,
	m.measurement_order_date as lab_order_date,
	m.measurement_date as specimen_date,
	(date_part('hour',m.measurement_datetime)||':'||date_part('minute',m.measurement_datetime))::varchar(5) as specimen_time,
	coalesce(measurement_result_date, measurement_date) as result_date,
	(date_part('hour',m.measurement_result_datetime)||':'||date_part('minute',m.measurement_result_datetime))::varchar(5) as result_time,
	coalesce(m8.target_concept,'OT')::varchar(12) as result_qual,
	m.value_as_number::numeric(25,8) as result_num,
	m3.target_concept::varchar(2) as result_modifier,
	m4.target_concept::varchar(11) as result_unit,
	left(m.range_low::text,10)::varchar(10) as norm_range_low,
	(case when m5.target_concept in ('LT','LE')
	     then 'OT'
	     else coalesce(m5.target_concept,'EQ')
	end)::varchar(2) as norm_modifier_low,
	left(m.range_high::text,10)::varchar(10) as norm_range_high,
	(case when m6.target_concept in ('GT','GE')
	     then 'OT'
	     else coalesce(m6.target_concept,'EQ')
	end)::varchar(2) as norm_modifier_high,
	null::varchar(2) as abn_ind, -- null for now until new conventions evolve
	c1.concept_name::varchar(256) as raw_lab_name,
	m.measurement_id::varchar(256) as raw_lab_code,
	null::varchar(256) as raw_panel,
	(c2.concept_name || m.value_as_number::text)::varchar(256) as raw_result,
	unit_source_value as raw_unit,
	null::varchar(256) as raw_order_dept,
	null::varchar(256) as raw_facility_code,
	m.site as site
from
	SITE_pedsnet.measurement m
	left join vocabulary.concept c1 on m.measurement_concept_id = c1.concept_id and
	                                   c1.vocabulary_id = 'LOINC'
	left join vocabulary.concept c2 on m.operator_concept_id = c2.concept_id and
	                                   c2.domain_id = 'Meas Value Operator'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m1 on c1.concept_code = m1.source_concept_id and
	                                                                m1.source_concept_class = 'Lab name'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m3 on cast(m.operator_concept_id as text) = m3.source_concept_id and
	                                                               m3.source_concept_class = 'Result modifier'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m4 on cast(m.unit_concept_id as text)= m4.source_concept_id and
	                                                                m4.source_concept_class = 'Unit'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m5 on cast(m.range_low_operator_concept_id as text)= m5.source_concept_id and
	                                                                m5.source_concept_class = 'Result modifier'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m6 on cast(m.range_high_operator_concept_id as text)= m6.source_concept_id and
	                                                                m6.source_concept_class = 'Result modifier'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m7 on cast(m.priority_concept_id as text)= m7.source_concept_id and
	                                                                m7.source_concept_class = 'Lab priority'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m8 on cast(m.value_as_concept_id as text)= m8.source_concept_id and
	                                                                m7.source_concept_class = 'Result qualifier'
    where measurement_type_Concept_id = 44818702 and
          person_id in (select person_id from SITE_pcornet.person_visit_start2001) and
          visit_occurrence_id is not null and
          visit_occurrence_id in (select visit_id from SITE_pcornet.person_visit_start2001);

commit;