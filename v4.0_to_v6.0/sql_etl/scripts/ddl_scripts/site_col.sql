create or replace function add_site_col(_schema character varying) returns void as
$BODY$
declare
	select_row record;
begin
for select_row in
	select 'alter table '|| _schema || '.' || tablename ||' add column site character varying not NULL;' as query
    from pg_tables
    where schemaname = _schema
	and tablename not in ('person_visit_start2001','harvest','version_history')
    loop
    execute select_row.query;
    end loop;
end;
$BODY$
language plpgsql;

select * from add_site_col('site');
