# region Import
import fileinput
import os
import re
import time
import datetime
from loading import query
import psycopg2
import config
import subprocess
import glob
import io

# endregion

# region file names
configfile_name = "database.ini"
etl_dir = "scripts/etl_scripts_temp"
view = "scripts/view-creation/func_upper_tbl_name.sql"
truncated = "scripts/reset_tables_scripts/trunc_fk_idx.sql"
harvest_file = "data/harvest_data.csv"
etl_bash = "bash_script/etl_bash.sh"
comb_csv = "bash_script/combine_csv.sh"
data_dir = "data"
test_script_file = "scripts/temp/temp.sql"
test_etl_bash = "bash_script/test_etl_script.sh"


# endregion

# region DDL only
def ddl_only():
    """
    This function creates the DDL for the Transformation. Following steps are processed:
      1. Create the XX_3dot1_pcornet schema and XX_3dot1_start2001_pcornet
      2. Create the DDL for PCORnet
      3. Create and populate the valueset map require to map the PEDSnet to PCORNet values
      3. Alter table to add a column for the site
      4. Populate the harvest table
      5. Set the permission for pcor_et_user and pcornet_sas user.
    """
    conn = None
    maps = False

    try:
        # region read connection parameters
        params = config.config('db')
        pcornet_version = config.config('pcornet_version')
        schema_path = config.config('schema')
        schema = [(re.sub('_pedsnet', '', schema_path['schema']) + """_pcornet""")]
        # endregion

        # region connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
        # create a cursor
        cur = conn.cursor()
        # endregion

        # region check if maps loaded
        cur.execute("""select exists (select 1 from information_schema.tables
                                               where table_schema = 'pcornet_maps' and table_name = 'pedsnet_pcornet_valueset_map'
                                               )
                            """)
        table_exists = cur.fetchone()[0]
        if not table_exists:
           # load_maps()
           print('load maps')

        # endregion

        for schemas in schema:
            # region check if the schema exisit
            cur.execute(
                """select exists(select 1 from information_schema.schemata where schema_name = \'""" + schemas + """\');""")
            schema_exist = cur.fetchone()[0]

            if not schema_exist:
                print('% schema does not exist..... \n Creating schema ....' % schemas)
                cur.execute(query.create_schema(schemas))
                print('% schema created' % schemas)
                conn.commit()
            # set the search pat to the schema
            cur.execute("SET search_path TO " + schemas + ";")
            time.sleep(0.1)
            # endregion

            # region run the DDL
            try:
                print('\nRunning the DDL ...')
                # set the search pat to the schema
                cur.execute("SET search_path TO " + schemas + ";")
                time.sleep(0.1)
                cur.execute(query.dll(pcornet_version))
                conn.commit()
            except (Exception, psycopg2.OperationalError) as error:
                print(error)
            # endregion

            # region Alter tables and add site column
            try:
                print('\nAltering table, adding {site} column ...')
                cur.execute("SET search_path TO " + schemas + ";")
                cur.execute(query.site_col(schemas))
                conn.commit()
            except(Exception, psycopg2.OperationalError) as error:
                print(error)
            # endregion

            # region permissions
            try:
                print('\nSetting permissions')
                cur.execute("SET search_path TO " + schemas + ";")
                time.sleep(0.1)
                cur.execute(query.permission(schemas))
                conn.commit()
            except(Exception, psycopg2.OperationalError) as error:
                print(error)
            # endregion

            # region Alter owner of tables
            try:
                cur.execute("SET search_path TO " + schemas + ";")
                time.sleep(0.1)
                cur.execute(query.owner(schemas))
                conn.commit()
            except(Exception, psycopg2.OperationalError) as error:
                print(error)
            # endregion

            # region Populate Harvest
            try:
                print('\nPopulating harvest table... ')
                if os.path.isfile(harvest_file):
                    f = open('data/harvest_data.csv', 'r')
                    cur.copy_from(f, schemas + ".harvest", columns=("admit_date_mgmt",
                                                                    "birth_date_mgmt",
                                                                    "cdm_version",
                                                                    "datamart_claims",
                                                                    "datamart_ehr",
                                                                    "datamart_name",
                                                                    "datamart_platform",
                                                                    "datamartid",
                                                                    "death_date_mgmt",
                                                                    "discharge_date_mgmt",
                                                                    "dispense_date_mgmt",
                                                                    "enr_end_date_mgmt",
                                                                    "enr_start_date_mgmt",
                                                                    "lab_order_date_mgmt",
                                                                    "measure_date_mgmt",
                                                                    "medadmin_start_date_mgmt",
                                                                    "medadmin_stop_date_mgmt",
                                                                    "network_name", "networkid",
                                                                    "obsclin_date_mgmt",
                                                                    "obsgen_date_mgmt",
                                                                    "onset_date_mgmt",
                                                                    "pro_date_mgmt",
                                                                    "px_date_mgmt",
                                                                    "refresh_condition_date",
                                                                    "refresh_death_cause_date",
                                                                    "refresh_death_date",
                                                                    "refresh_demographic_date",
                                                                    "refresh_diagnosis_date",
                                                                    "refresh_dispensing_date",
                                                                    "refresh_encounter_date",
                                                                    "refresh_enrollment_date",
                                                                    "refresh_lab_result_cm_date",
                                                                    "refresh_med_admin_date",
                                                                    "refresh_obs_clin_date",
                                                                    "refresh_obs_gen_date",
                                                                    "refresh_pcornet_trial_date",
                                                                    "refresh_prescribing_date",
                                                                    "refresh_pro_cm_date",
                                                                    "refresh_procedures_date",
                                                                    "refresh_provider_date",
                                                                    "refresh_vital_date",
                                                                    "report_date_mgmt",
                                                                    "resolve_date_mgmt",
                                                                    "result_date_mgmt",
                                                                    "rx_end_date_mgmt",
                                                                    "rx_order_date_mgmt",
                                                                    "rx_start_date_mgmt",
                                                                    "specimen_date_mgmt"), sep=",")
                    conn.commit()
            except (Exception, psycopg2.DatabaseError) as error:
                print(error)
            # endregion
        print('\nPcornet data model set up complete ... \nClosing database connection...')
        cur.close()
    except (Exception, psycopg2.OperationalError) as error:
        print(error)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    except (Exception, psycopg2.ProgrammingError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')


# endregion

# region Full  Pipeline
def pipeline_full():
    ddl_only()
    etl_only()


# endregion

# region Truncate and remove FK
def truncate_fk():
    conn = None
    try:
        # region read connection parameters
        params = config.config('db')
        schema_path = config.config('schema')
        # schema = schema_path['schema']+"""_3dot1_pcornet"""
        schema = [(re.sub('_pedsnet', '', schema_path['schema']) + """_pcornet""")]
        # endregion

        # region connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
        # endregion
        # create a cursor
        cur = conn.cursor()

        # region Check if Function exists
        # cur.execute("""SELECT EXISTS(SELECT * FROM pg_proc WHERE proname = 'truncate_schema')""")
        # fun_exist = cur.fetchall()[0]
        # if "True" not in fun_exist:
        #     cur.execute(open(truncate, 'r').read())
        with open(truncated, 'r') as truncate:
            commands = truncate.read()
        cur.execute(commands)
        conn.commit()
        for schemas in schema:
            # query.truncate(schema)
            cur.execute("SET search_path TO " + schemas + ";")
            query.truncateqry(schemas)
            print('Truncated')
            conn.commit()
        cur.close()
        # endregion
    except (Exception, psycopg2.OperationalError) as error:
        print(error)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    except (Exception, psycopg2.ProgrammingError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')


# endregion

# region ETL only
def etl_only():
    schema_path = config.config('schema')
    schema = re.sub('_pedsnet', '', schema_path['schema'])

    query.get_etl_ready(schema)
    # subprocess.call("ls -la", shell=True)  stdout=subprocess.PIPE,

    filelist = glob.glob(os.path.join(etl_dir, '*.sql'))
    for infile in sorted(filelist):
        args = infile

        print('starting ETL \t:' + datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S') + "\n")
        proc = subprocess.Popen([etl_bash, args], stderr=subprocess.STDOUT)
        output, error = proc.communicate()

        if output:
            with open("logs/log_file.log", "a") as logfile:
                logfile.write("\n" + datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S') + "\n")
                logfile.write(output)
        if error:
            with open("logs/log_file.log", "a") as logfile:
                logfile.write("\n" + datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S' + "\n"))
                logfile.write(error)

    # create the upper case views
    conn = None
    try:
        # region read connection parameters
        params = config.config('db')
        schema_path = config.config('schema')
        # schema = schema_path['schema']+"""_3dot1_pcornet"""
        schema = [(re.sub('_pedsnet', '', schema_path['schema']) + """_pcornet""")]
        # endregion

        # region connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
        # endregion
        cur = conn.cursor()
        cur.execute(open(view, "r").read())
        conn.commit()
        cur.execute("SET search_path TO " + schema[1] + ";")
        cur.execute("select capitalview(\'" + params[1] + "\',\'" + schema[1] + """\');""")
        conn.commit()
        for schemas in schema:
            cur.execute("SET search_path TO " + schemas + ";")
            time.sleep(0.1)
            cur.execute(query.permission(schemas))
            conn.commit()
            cur.execute("SET search_path TO " + schemas + ";")
            time.sleep(0.1)
            cur.execute(query.owner(schemas))
            conn.commit()
        cur.close
    except (Exception, psycopg2.OperationalError) as error:
        print(error)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    except (Exception, psycopg2.ProgrammingError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')
    print('ETL is complete')


# endregion

# region Update valueset map
def update_valueset():
    args = glob.glob(data_dir)
    proc = subprocess.Popen([comb_csv, args], shell=True, stderr=subprocess.STDOUT)
    output, error = proc.communicate()


# endregion

# region Harvest date refresh
def harvest_date_refresh(date):
    pattern = re.compile(r'\d{4}-\d{2}-\d{2}')
    for line in fileinput.input(harvest_file, inplace=1, backup='.bak'):
        line = re.sub(pattern, date, line.rstrip())
        print(line)


# endregion

# region Test the etl script
def test_script():
    args = test_script_file

    print('starting ETL \t:' + datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S') + "\n")
    proc = subprocess.Popen([test_etl_bash, args], stderr=subprocess.STDOUT)
    output, error = proc.communicate()

    if output:
        print(output)
    if error:
        print(error)


# endregion

# region Loading maps
def load_maps():
    conn = None
    try:
        # region read connection parameters
        params = config.config('db')
        schema = """pcornet_maps"""
        # endregion

        # region connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
        # create a cursor
        cur = conn.cursor()
        # endregion

        # region check if the schema exisit
        cur.execute(
            """select exists(select 1 from information_schema.schemata where schema_name = \'""" + schema + """\');""")
        schema_exist = cur.fetchone()[0]

        if not schema_exist:
            print('% schema does not exist..... \n Creating schema ....' % schema)
            cur.execute(query.create_schema(schema))
            print('% schema created' % schema)
            conn.commit()
            # set the search pat to the schema
            cur.execute("SET search_path TO " + schema + ";")
            time.sleep(0.1)
        # endregion

        # region create tables
        try:
            print('\ncreating and populating the mapping table ...')
            cur.execute(query.create_table(schema))
            conn.commit()

            # region import the file to the database
            if os.path.isfile('data/concept_map.csv'):
                f = io.open('data/concept_map.csv', 'r', encoding="utf8")
                cur.copy_from(f, schema + ".pedsnet_pcornet_valueset_map", columns=(
                  "source_concept_class",
                  "target_concept",
                   "pcornet_name",
                   "source_concept_id",
                   "concept_description",
                   "value_as_concept_id"),
                            sep=",")
                conn.commit()
        except (Exception, psycopg2.OperationalError) as error:
            print(error)
        # endregion

        # region permissions
        try:
            print('\nSetting permissions')
            cur.execute("SET search_path TO " + schema + ";")
            time.sleep(0.1)
            cur.execute(query.permission(schema))
            conn.commit()
        except(Exception, psycopg2.OperationalError) as error:
            print(error)
        # endregion

        # region Alter owner of tables
        try:
            cur.execute("""SET search_path TO """ + schema + """;""")
            time.sleep(0.1)
            cur.execute(query.owner(schema))
            conn.commit()
        except(Exception, psycopg2.OperationalError) as error:
            print(error)
        # endregion

        print('\nPcornet valueset map loaded ... \nClosing database connection...')
        cur.close()
    except (Exception, psycopg2.OperationalError) as error:
        print(error)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    except (Exception, psycopg2.ProgrammingError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')

# endregion
