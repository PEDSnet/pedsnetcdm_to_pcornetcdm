--create or replace function alter_tbl_owner(_schema character varying) returns void as
DO $$
declare
	select_row record;
        _schema text := 'SITE_pcornet';
begin
for select_row in
	select 'alter table '|| _schema || '.' || tablename ||' owner to pcor_et_user;' as query
    from pg_tables
    where schemaname = _schema
    loop
    execute select_row.query;
    end loop;
end;
$$
language plpgsql;

--perform alter_tbl_owner('SITE_pcornet');
