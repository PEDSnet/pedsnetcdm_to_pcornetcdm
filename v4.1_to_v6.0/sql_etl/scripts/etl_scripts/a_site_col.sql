--create or replace function add_site_col(_schema character varying) returns void as
DO $$
declare
	select_row record;
        _schema text := 'SITE_pcornet';
begin
for select_row in
	select 'alter table '|| _schema || '.' || tablename ||' add column site character varying(256);' as query
    from pg_tables
    where schemaname = _schema
	and tablename not in ('person_visit_start2001','harvest','version_history')
    loop
    execute select_row.query;
    end loop;
end;
$$ language plpgsql;

-- perform add_site_col('SITE_pcornet');
