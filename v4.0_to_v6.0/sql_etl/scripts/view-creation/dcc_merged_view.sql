/* 
Updating the function to add the materialized view instead of regular views fro dcc_pcornet.
This function is used to create the materialized lower case view 
and the capatilized view for the merged dcc_pcornet data
*/
create or replace function capitalview_dcc(datab text, schemanm text) returns void as $$
	declare
        tbl_array text[];
        col_name text[];
        count_tbl integer;
        count_col integer;
		updatestr text;
        sqlstr text;
		sqlcapstr text;
        sel_stat text;
		sel_cap_stat text;
    begin
    	select array(
            			SELECT tablename as table
					   	FROM pg_tables
						WHERE schemaname = 'nemours_pcornet'
			            and tablename = 'harvest'
                     ) into tbl_array;
        select (select count(*) FROM pg_tables
						WHERE schemaname = 'nemours_pcornet'
			   ) into count_tbl;
    	<<table_loop>>
        for i in 1.. count_tbl  loop
        	select (
            			SELECT array_agg(column_name::text)
					   	FROM information_schema.columns
						WHERE table_schema = 'nemours_pcornet' 
  						AND table_name   = tbl_array[i]
                     ) into col_name;
             select (
            			SELECT count(column_name)
					   	FROM information_schema.columns
						WHERE table_schema = 'nemours_pcornet'
  						AND table_name   = tbl_array[i]
                     ) into count_col;
              <<column_loop>>
              for j in 1.. count_col loop
              		sel_stat := concat_ws(',', sel_stat, tbl_array[i]||'.'||col_name[j]);
              		sel_cap_stat := concat_ws(',', sel_cap_stat, tbl_array[i]||'.'||col_name[j]||' as "'||upper(col_name[j])||'"');  -- uppercase column names.
              end loop column_loop;
			  if (tbl_array[i] in ('harvest')) then
			  	sqlstr = 'create table dcc_pcornet.harvest as SELECT address_period_end_mgmt, address_period_start_mgmt, admit_date_mgmt, birth_date_mgmt, cdm_version, datamart_claims, datamart_ehr, ''PEDSnet''::character varying(20) as datamart_name, datamart_platform, ''C7CPED''::character varying(10) as datamartid, death_date_mgmt, discharge_date_mgmt, dispense_date_mgmt, dx_date_mgmt, enr_end_date_mgmt, enr_start_date_mgmt, lab_order_date_mgmt, measure_date_mgmt, medadmin_start_date_mgmt, medadmin_stop_date_mgmt, network_name, networkid, obsclin_date_mgmt, obsgen_date_mgmt, onset_date_mgmt, pro_date_mgmt, px_date_mgmt, refresh_condition_date, refresh_death_cause_date, refresh_death_date, refresh_demographic_date, refresh_diagnosis_date, refresh_dispensing_date, refresh_encounter_date, refresh_enrollment_date, refresh_hash_token_date, refresh_immunization_date, refresh_lab_result_cm_date, refresh_lds_address_hx_date, refresh_med_admin_date, refresh_obs_clin_date, refresh_obs_gen_date, refresh_pcornet_trial_date, refresh_prescribing_date, refresh_pro_cm_date, refresh_procedures_date, refresh_provider_date, refresh_vital_date, report_date_mgmt, resolve_date_mgmt, result_date_mgmt, rx_end_date_mgmt, rx_order_date_mgmt, rx_start_date_mgmt, specimen_date_mgmt, vx_admin_date_mgmt, vx_exp_date_mgmt, vx_record_date_mgmt
from nationwide_pcornet.harvest;';
                sqlcapstr = 'CREATE VIEW '||schemanm||'."'||upper(tbl_array[i])||'" AS SELECT '||sel_cap_stat||' FROM dcc_pcornet.'||tbl_array[i]||';'; 
			  elsif (tbl_array[i] in ('pro_cm','version_history','pcornet_trial','private_address_geocode','private_address_history','version_history')) then
			  	sqlstr = 'CREATE Materialized VIEW '||schemanm||'.'||tbl_array[i]||' AS SELECT '||sel_stat||' FROM nationwide_pcornet.'||tbl_array[i]||';';
				sqlcapstr = 'CREATE VIEW '||schemanm||'."'||upper(tbl_array[i])||'" AS SELECT '||sel_cap_stat||' FROM dcc_pcornet.'||tbl_array[i]||';';
			  else
        	  	sqlstr = 'CREATE Materialized VIEW '||schemanm||'.'||tbl_array[i]||' AS
						SELECT '||sel_stat||' FROM nationwide_pcornet.'||tbl_array[i]||'
						union
						SELECT '||sel_stat||' FROM nemours_pcornet.'||tbl_array[i]||'
						union
						SELECT '||sel_stat||' FROM seattle_pcornet.'||tbl_array[i]||'
						union
						SELECT '||sel_stat||' FROM stlouis_pcornet.'||tbl_array[i]||';';
				sqlcapstr = 'CREATE VIEW '||schemanm||'."'||upper(tbl_array[i])||'" AS
						SELECT '||sel_cap_stat||' FROM dcc_pcornet.'||tbl_array[i]||';';
	          end if;
              execute sqlstr; 
			  execute sqlcapstr;
			  sel_stat := null;
			  sel_cap_stat := null;
        end loop table_loop;
	end;
$$ LANGUAGE plpgsql;

select count(*) from capitalview_dcc('pedsnet_dcc_v38', 'dcc_pcornet')
																				  
																				  
																				  
																				  