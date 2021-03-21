create or replace function alter_tbl_owner(_schema character varying) returns void as
$BODY$
declare
	select_row record;
begin
for select_row in
	select 'alter table '|| _schema || '.' || tablename ||' owner to pcor_et_user;' as query
    from pg_tables
    where schemaname = _schema
    loop
    execute select_row.query;
    end loop;
end;
$BODY$
language plpgsql;