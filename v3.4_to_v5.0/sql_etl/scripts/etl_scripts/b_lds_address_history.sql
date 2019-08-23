begin;

INSERT INTO SITE_pcornet.lds_address_history(
	address_city, address_period_end, address_period_start, address_preferred, address_state, address_type, address_use, address_zip5, address_zip9, addressid, patid, site)
select
	l.city as address_city,
	lh.start_date as address_period_end,
	lh.end_date as address_period_start,
	lh.location_preferred_concept_id  as address_preferred,
	l.state as address_state,
	lh.relation_type_concept_id as address_type,
	null as address_use,
	null as address_zip5,
	null as address_zip9,
	l.location_id::text as addressid,
	lh.entity_id as patid,
	l.site
from SITE_pedsnet.location l
left join SITE_pedsnet.location_history lh on l.location_id = lh.location_id
where patid in (select person_id from SITE_pcornet.person_visit_start2001);

commit;