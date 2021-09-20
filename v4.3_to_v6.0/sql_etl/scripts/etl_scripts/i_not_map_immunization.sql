begin;
with not_mapping as
(
        select immunizationid from SITE_pcornet.immunization where vx_code = ''
)
update SITE_pcornet.immunization
set vx_code = coalesce(c.concept_code,'')
from not_mapping i
left join SITE_pedsnet.immunization im on im.immunization_id = i.immunizationid::int
left join vocabulary.concept c on c.concept_name @@ im.immunization_source_value
                                and concept_class_id = 'CVX'
where SITE_pcornet.immunization.immunizationid = i.immunizationid;
commit;
