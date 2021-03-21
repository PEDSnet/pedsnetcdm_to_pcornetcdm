/*
	This function checks the PCORnet harmonization and 
	if the data type for the stable id's are not harmonizing then it will harmonized it.
*/
create or replace function harmonization_check(_site character varying) returns void as
$BODY$
declare
	stat text;
	rslt record;
begin
stat := 'select table_schema, table_name, column_name,data_type, character_maximum_length 
from information_schema.columns 
where (column_name in (''patid'',''encounterid'',''procedureid'',''prescribingid'') or column_name ilike ''%providerid%'')
and table_schema = ''' || _site ||'''
and table_name in (''condition'',''death'',''death_cause'',''demographic'',''diagnosis'',
''dispensing'',''encounter'',''enrollment'',''harvest'',''hash_token'',''immunization'',
''lab_history'',''lab_result_cm'',''lds_address_history'',''med_admin'',''obs_clin'',''obs_gen'',
''pcornet_trial'',''prescribing'',''private_address_geocode'',''private_address_history'',
''private_demographic'',''pro_cm'',''procedures'',''provider'',''version_history'',''vital'')
and data_type != ''character varying''
and character_maximum_length != 256;'; 

execute stat INTO rslt;
if rslt is null then
RAISE NOTICE 'All Variables harmonized...';
else
for select_row in
	select 'alter table '|| table_schema || '.' || table_name ||' alter column '|| column_name ||'type character varying(256) using '||column_name||'::character varying(256);' as query
    from rslt
    loop
    execute select_row.query;
    end loop;
END IF;
END;
$BODY$
language plpgsql;

select harmonization_check('SITE_pcornet');

