begin;

insert into SITE_pcornet.private_address_geocode(
    geocodeid,
    addressid,
    geocode_state,
    geocode_county,
    geocode_tract,
    geocode_group,
    geocode_block,
    geocode_custom_text,
    shapefile
)
select 
    fips.geocode_id::varchar as geocodeid,
    his.location_history_id::varchar as addressid,
    geocode_state as geocode_state,
    geocode_county as geocode_county,
    geocode_tract as geocode_tract, 
    geocode_group as geocode_group,
    geocode_block as geocode_block,
    geocode_year::varchar as geocode_custom_text,
    geocode_shapefile as shapefile
from 
    SITE_pedsnet.location_history his
left join 
    SITE_pedsnet.location_fips fips
    on fips.location_id = his.location_id
inner join
    SITE_pcornet.lds_address_history lds 
    on lds.addressid = his.location_history_id::varchar;
commit;