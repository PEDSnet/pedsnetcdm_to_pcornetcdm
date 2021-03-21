CREATE OR REPLACE FUNCTION drop_view_schema(_schema character varying) RETURNS void AS
$BODY$
DECLARE r record;
 s TEXT;
BEGIN
            FOR r IN select table_schema,table_name
                     from information_schema.views
                     where table_schema = _schema
            LOOP
                s := 'DROP VIEW ' ||  quote_ident(r.table_schema) || '.' || quote_ident(r.table_name) || ';';

                EXECUTE s;

                RAISE NOTICE 's = % ',s;

            END LOOP;
        END;
$BODY$
  LANGUAGE plpgsql;
  
  
select * from drop_view_schema('SITE_pcornet')