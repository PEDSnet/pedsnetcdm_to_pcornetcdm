begin;

INSERT INTO SITE_pcornet.lds_address_history(
	address_city, address_period_end, address_period_start, address_preferred, address_state, address_type, address_use, address_zip5, address_zip9, addressid, patid, site)
select
	case when loc.city ~ '^[0-9]+$' then null 
	     when loc.city ~ '[^[:alnum:] ]' then case when regexp_replace(loc.city, '[^\w]+','') = '' then null 
		                                            else regexp_replace(loc.city, '[^\w]',' ') 
													end 
		 else loc.city end as address_city, 
	loc_his.end_date as address_period_end, 
	loc_his.start_date as address_period_start, 
	coalesce(addr_pref.target_concept,'Y')  as address_preferred, 
	coalesce(addr_st.target_concept, 'NI') as address_state, 
	coalesce(addr_typ.target_concept, 'BO') as address_type, 
	'HO' as address_use, 
	case when length(loc.zip)= 5 and zip ~ '^[0-9]+$' then loc.zip else null end as address_zip5, 
	case when length(replace(loc.zip,'-',''))= 9 and replace(loc.zip,'-','') ~ '^[0-9]+$' then left(replace(loc.zip,'-',''),9) else null end as address_zip9, 
	loc_his.location_history_id::text as addressid, 
	loc_his.entity_id::text as patid, 
	'SITE' as site
from SITE_pedsnet.location loc 
left join SITE_pedsnet.location_history loc_his on loc.location_id = loc_his.location_id and lower(loc_his.domain_id) = 'person'
left join pcornet_maps.pedsnet_pcornet_valueset_map addr_pref on addr_pref.source_concept_id::int = loc_his.location_preferred_concept_id and addr_pref.source_concept_class = 'address_preferred'
left join pcornet_maps.pedsnet_pcornet_valueset_map addr_typ on addr_typ.source_concept_id::int = loc_his.relationship_type_concept_id and addr_typ.source_concept_class = 'address_type'
left join pcornet_maps.pedsnet_pcornet_valueset_map addr_st on case when length(loc.state) = 2 then lower(trim(split_part(addr_st.pcornet_name,'=',1))) = lower(loc.state) 
															    else lower(trim(split_part(addr_st.pcornet_name,'=',2))) = lower(loc.state) 
																end 
                                                          and addr_st.source_concept_class = 'address_state'
where loc_his.entity_id in (select person_id from SITE_pcornet.person_visit_start2001);

commit;