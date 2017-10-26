-- this functions truncates, removes fK and index from all the tables in provided schema
CREATE OR REPLACE FUNCTION truncate_schema(_schema character varying)
  RETURNS void AS
$BODY$
DECLARE
    selectrow record;
    select_index record;
    select_fk record;
BEGIN
	FOR selectrow in
		SELECT 'TRUNCATE TABLE ' || quote_ident(_schema) || '.' ||quote_ident(t.table_name) || ' CASCADE; ' AS qry
		FROM (
     			SELECT table_name
     			FROM information_schema.tables
     			WHERE table_type = 'BASE TABLE' AND table_schema = _schema
     		)t
	LOOP
		EXECUTE selectrow.qry;
	END LOOP;
    -- -------------------------  drop all indexes  ----------------------------------------------
    FOR select_index in
    	SELECT 'DROP INDEX ' || quote_ident(_schema) || '.' || quote_ident(i.indexname) ||';' AS query_idx
        FROM (
        		SELECT indexname, tablename, schemaname
            	FROM pg_indexes
            	WHERE indexname LIKE 'idx_%' AND
                      schemaname = _schema AND
                      tablename in (
                					  SELECT table_name
     								  FROM information_schema.tables
     								  WHERE table_type = 'BASE TABLE' AND
                                            table_schema =  _schema
                					)
        	 )i
     LOOP
     	EXECUTE select_index.query_idx;
     END LOOP;
     -- -----------------------  drop all foreign key constraints   -------------------------------------
     FOR select_fk in
     	 SELECT 'ALTER TABLE '|| quote_ident(_schema) ||'.' || quote_ident(tbl.table_name) ||' DROP CONSTRAINT ' || tbl.constraint_name ||';' AS query_fk
         FROM (
         		SELECT constraint_name, table_name
         	  	FROM information_schema.table_constraints
                WHERE table_schema = _schema AND
                      constraint_name like '%_fk_%'
              )tbl
     LOOP
     	EXECUTE select_fk.query_fk;
     END LOOP;
end;
$BODY$
  LANGUAGE plpgsql;
-- endregion function


--  To call the function put the schema name that you want to remove constraints, index and truncate.
--  ex. select truncate_schema('employee')

select truncate_schema('stlouis_3dot1_start2001_pcornet');