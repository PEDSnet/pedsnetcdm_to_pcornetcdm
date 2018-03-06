begin;
/*
-- filtering the people for the visit starting 2001
create table SITE_pcornet.demographic_person
as
select person_id, year_of_birth, month_of_birth, day_of_birth, birth_datetime, gender_concept_id, ethnicity_concept_id, 
       race_concept_id, gender_source_value, ethnicity_source_value, race_source_value, null::varchar(1) as gender_identity,
       null::varchar(256) as raw_gender_identity, , site
from SITE_pedsnet.person
where person_id in (select person_id from SITE_pcornet.person_visit_start2001);
*/

-- create the demographics table from the filtered patients
create table SITE_pcornet.demographic
as
-- formatting the table
select distinct
	cast(p.person_id as text) as patid,
	cast(
          cast(year_of_birth as text)||
          (
            case when month_of_birth is null 
                then '-01' 
                else '-'||lpad(cast(month_of_birth as text),2,'0') 
                end
           )||
          (
              case when day_of_birth is null 
                   then '-01' 
                   else '-'||lpad(cast(day_of_birth as text),2,'0') 
                   end
          )as date
        )as birth_date,
	(LPAD(date_part('hour',birth_datetime)::text,2,'0')||':'||LPAD(date_part('minute',birth_datetime)::text,2,'0'))::varchar(5) as birth_time,
	coalesce (m1.target_concept,'OT')::varchar(2) as sex,
	gender_source_value::varchar(256) as raw_sex,
	null::varchar(2) as sexual_orientation,
	null::varchar(256) as raw_sexual_orientation,
    null::varchar(1) as gender_identity,
    null::varchar(256) as raw_gender_identity,
	coalesce (m2.target_concept,'OT')::varchar(2) as hispanic,
	coalesce (m3.target_concept,'OT')::varchar(2) as race,
	'N'::varchar(1) as biobank_flag,
	ethnicity_source_value::varchar(256) as raw_hispanic,
	race_source_value::varchar(256) as raw_race,
	site::varchar(256) as site
from
	SITE_pedsnet.person p
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m1 on case when cast(p.gender_concept_id as text) is null AND m1.source_concept_id is null 
                                                                      then true 
                                                                      else cast(p.gender_concept_id as text) = m1.source_concept_id 
                                                                      end 
                                                              and m1.source_concept_class='Gender'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m2 on case when p.ethnicity_concept_id is null AND m2.source_concept_id is null 
                                                                      then true 
                                                                      else cast(p.ethnicity_concept_id as text) = m2.source_concept_id 
                                                                      end 
                                                              and m2.source_concept_class='Hispanic'
	left join SITE_pcornet.pedsnet_pcornet_valueset_map m3 on case when p.race_concept_id is null AND m3.source_concept_id is null 
                                                                      then true 
                                                                      else cast(p.race_concept_id as text) = m3.source_concept_id 
                                                                      end 
                                                              and m3.source_concept_class = 'Race'
    where person_id in (select person_id from SITE_pcornet.person_visit_start2001);


                                                              
 -- drop the not required table
 -- drop table SITE_pcornet.demographic_person;

commit;