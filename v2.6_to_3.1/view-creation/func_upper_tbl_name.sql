-- views
create or replace function capitalview(datab text, schemanm text) returns void as $$
	declare 
        tbl_array text[];
        col_name text[];
        count_tbl integer;
        count_col integer;
        sqlstr text;
        sel_stat text;
    begin
    	select array(
            			SELECT tablename as table
					   	FROM pg_tables
						WHERE schemaname = schemanm
                     ) into tbl_array;
        select (select count(*) FROM pg_tables
						WHERE schemaname = schemanm) into count_tbl;
    	<<table_loop>>
        for i in 1.. count_tbl  loop
        	select (
            			SELECT array_agg(column_name::text)
					   	FROM information_schema.columns
						WHERE table_schema = schemanm
  						AND table_name   = tbl_array[i]
                     ) into col_name;
             select (
            			SELECT count(column_name)
					   	FROM information_schema.columns
						WHERE table_schema = schemanm
  						AND table_name   = tbl_array[i]
                     ) into count_col;
              <<column_loop>>
              for j in 1.. count_col loop
              		sel_stat := concat_ws(',', sel_stat, tbl_array[i]||'.'||col_name[j]);
              		-- sel_stat := concat_ws(',', sel_stat, tbl_array[i]||'.'||col_name[j]||' as "'||upper(col_name[j])||'"');  -- uppercase column names.
              end loop column_loop;
        	  sqlstr = 'CREATE OR REPLACE VIEW '||schemanm||'."'||upper(tbl_array[i])||'" AS
                        SELECT '||sel_stat||' FROM '||schemanm||'.'||tbl_array[i]||';';
              execute sqlstr;
              sel_stat := null;
        end loop table_loop;	
	end;
$$ LANGUAGE plpgsql;

select count(*) from capitalview('pedsnet_dcc_v25', 'dcc_pcornet')
