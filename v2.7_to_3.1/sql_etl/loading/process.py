# region Import
import fileinput
import os
import re
import time
import datetime
import query
import psycopg2
import config
import subprocess
import glob

# endregion

# region file names
configfile_name = "database.ini"
etl_dir = "scripts/etl_scripts_temp"
view = "scripts/view-creation/func_upper_tbl_name.sql"
truncated = "scripts/reset_tables_scripts/trunc_fk_idx.sql"

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

    try:
        # region read connection parameters
        params = config.config('db')
        schema_path = config.config('schema')
        # schema = schema_path['schema']+"""_3dot1_pcornet"""
        schema = [(re.sub('_pedsnet', '', schema_path['schema']) + """_3dot1_pcornet"""),
                  (re.sub('_pedsnet', '', schema_path['schema']) + """_3dot1_start2001_pcornet""")]
        # endregion

        # region connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
        # create a cursor
        cur = conn.cursor()
        # endregion

        # region Check if there is already a configuration file
        #if os.path.isfile(configfile_name):
            # delete the file
            #os.remove(configfile_name)
        # endregion

        for schemas in schema:
            # region check if the schema exisit
            cur.execute(
                """select exists(select 1 from information_schema.schemata where schema_name = \'""" + schemas + """\');""")
            schema_exist = cur.fetchall()[0]

            if "True" not in schema_exist:
                print '% schema does not exist..... \n Creating schema ....' % schemas
                cur.execute(query.create_schema(schemas))
                print '% schema created' % schemas
                conn.commit()
            # set the search pat to the schema
            cur.execute("""SET search_path TO """ + schemas + """;""")
            time.sleep(0.1)
            # endregion

            # region create mapping table
            try:
                print '\ncreating and populating the mapping table ...'
                cur.execute(query.create_table(schemas))
                conn.commit()

                # region import the file to the database
                if os.path.isfile('data/concept_map.csv'):
                    f = open('data/concept_map.csv', 'r')
                    cur.copy_from(f, schemas + ".pedsnet_pcornet_valueset_map", columns=("target_concept",
                                                                                         "source_concept_class",
                                                                                         "source_concept_id",
                                                                                         "value_as_concept_id",
                                                                                         "concept_description"),
                                  sep=",")
                    conn.commit()
            except (Exception, psycopg2.OperationalError) as error:
                print(error)
            # endregion

            # region run the DDL
            try:
                print '\nRunning the DDL ...'
                # set the search pat to the schema
                cur.execute("""SET search_path TO """ + schemas + """;""")
                time.sleep(0.1)
                cur.execute(query.dll())
                conn.commit()
            except (Exception, psycopg2.OperationalError) as error:
                print(error)
            # endregion

            # region Alter tables and add site column
            try:
                print '\nAltering table, adding {site} column ...'
                cur.execute("""SET search_path TO """ + schemas + """;""")
                cur.execute(query.site_col(schemas))
                conn.commit()
            except(Exception, psycopg2.OperationalError) as error:
                print(error)
            # endregion

            # region permissions
            try:
                print '\nSetting permissions'
                cur.execute("""SET search_path TO """ + schemas + """;""")
                time.sleep(0.1)
                cur.execute(query.permission(schemas))
                conn.commit()
            except(Exception, psycopg2.OperationalError) as error:
                print(error)
            # endregion

            # region Alter owner of tables
            try:
                cur.execute("""SET search_path TO """ + schemas + """;""")
                time.sleep(0.1)
                cur.execute(query.owner(schemas))
                conn.commit()
            except(Exception, psycopg2.OperationalError) as error:
                print(error)
            # endregion

            # region Populate Harvest
            try:
                print '\nPopulating harvest table... '
                if os.path.isfile('data/harvest_data.csv'):
                    f = open('data/harvest_data.csv', 'r')
                    cur.copy_from(f, schemas + ".harvest", columns=("admit_date_mgmt",
                                                                    "birth_date_mgmt",
                                                                    "cdm_version",
                                                                    "datamart_claims",
                                                                    "datamart_ehr",
                                                                    "datamart_name",
                                                                    "datamart_platform",
                                                                    "datamartid",
                                                                    "discharge_date_mgmt",
                                                                    "dispense_date_mgmt",
                                                                    "enr_end_date_mgmt",
                                                                    "enr_start_date_mgmt",
                                                                    "lab_order_date_mgmt",
                                                                    "measure_date_mgmt",
                                                                    "network_name", "networkid",
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
                                                                    "refresh_pcornet_trial_date",
                                                                    "refresh_prescribing_date",
                                                                    "refresh_pro_cm_date",
                                                                    "refresh_procedures_date",
                                                                    "refresh_vital_date",
                                                                    "report_date_mgmt",
                                                                    "resolve_date_mgmt",
                                                                    "result_date_mgmt",
                                                                    "rx_end_date_mgmt",
                                                                    "rx_order_date_mgmt",
                                                                    "rx_start_date_mgmt",
                                                                    "specimen_date_mgmt"),
                                  sep=",")
                    conn.commit()
            except (Exception, psycopg2.OperationalError) as error:
                print(error)
                # endregion
        print '\nPcornet data model set up complete ... \nClosing database connection...'
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
        schema = [(re.sub('_pedsnet', '', schema_path['schema']) + """_3dot1_pcornet"""),
                  (re.sub('_pedsnet', '', schema_path['schema']) + """_3dot1_start2001_pcornet""")]
        # endregion

        # region connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
        # endregion
        # create a cursor
        cur = conn.cursor()

        # region Check if Function exists

        #cur.execute("""SELECT EXISTS(SELECT * FROM pg_proc WHERE proname = 'truncate_schema')""")
        #fun_exist = cur.fetchall()[0]
        #if "True" not in fun_exist:
        #    cur.execute(open(truncate, 'r').read())

        with open(truncated, 'r') as truncate:
            commands = truncate.read()
        cur.execute(commands)
        conn.commit()
        for schemas in schema:
            cur.execute("""SET search_path TO """ + schemas + """;""")
            query.truncateqry(schemas)
            conn.commit()
        print('Truncated')
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

        print 'starting ETL \t:' + datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S') + "\n"
        proc = subprocess.Popen(['bash_script/etl_bash.sh', args], stderr=subprocess.STDOUT)
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
        schema = [(re.sub('_pedsnet', '', schema_path['schema']) + """_3dot1_pcornet"""),
                  (re.sub('_pedsnet', '', schema_path['schema']) + """_3dot1_start2001_pcornet""")]
        # endregion

        # region connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
        # endregion
        cur = conn.cursor()
        cur.execute(open(view, "r").read())
        conn.commit()
        for schemas in schema:
            cur.execute("""select count(*) from capitalview('pedsnet_dcc_v27',\'""" + schemas + """\')""")
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
    print 'ETL is complete'


# endregion

# region Update valueset map
def update_valueset():
    conn = None

    try:
        # region read connection parameters
        params = config.config('db')
        schema_path = config.config('schema')
        # schema = schema_path['schema']+"""_3dot1_pcornet"""
        schema = [(re.sub('_pedsnet', '', schema_path['schema']) + """_3dot1_pcornet"""),
                  (re.sub('_pedsnet', '', schema_path['schema']) + """_3dot1_start2001_pcornet""")]
        # endregion

        # region connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
        # endregion

        # create a cursor
        cur = conn.cursor()

        # region Both schema update map
        for schemas in schema:
            # region check if the schema exisit
            cur.execute(
                """select exists(select 1 from information_schema.schemata where schema_name = \'""" + schemas + """\');""")
            schema_exist = cur.fetchall()[0]

            if "True" not in schema_exist:
                print '% ERROR: schema does not exist.....' % schemas
            else:
                # set the search path to the schema
                cur.execute("""SET search_path TO """ + schemas + """;""")
                time.sleep(0.1)
                # endregion

                # region update the table.
                try:
                    # region update the concept map table
                    if os.path.isfile('data/update_valueset.csv'):

                        for line in fileinput.input('data/update_valueset.csv', inplace=1):
                            line = re.sub('"*?\ ', "", line.rstrip())
                            print(line)
                        f = open('data/update_valueset.csv', 'r')
                        cur.copy_from(f, schemas + ".pedsnet_pcornet_valueset_map", columns=("target_concept",
                                                                                             "source_concept_class",
                                                                                             "source_concept_id",
                                                                                             "value_as_concept_id",
                                                                                             "concept_description"),
                                      sep=",")
                        cur.statusmessage
                        conn.commit()
                    # endregion

                    # region download the updated concept map data
                    os.rename('data/concept_map.csv', 'data/concept_map' + datetime.date.today().strftime("%b%d%y")
                              + '.csv' + ".bak")
                    cur.copy_to('data/concept_map.csv', schema + ".pedsnet_pcornet_valueset_map", sep=",")
                    cur.statusmessage
                    conn.commit()
                    # endregion

                except (Exception, psycopg2.OperationalError) as error:
                    print(error)
                    # endregion
        # endregion

        print '\nPcornet valueset update complete ... \nClosing database connection...'
        disconnect(cur)
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


# endregion

# region connect
def connection():
    conn = None

    try:
        # region read connection parameters
        params = config.config('db')
        schema_path = config.config('schema')
        # schema = schema_path['schema']+"""_3dot1_pcornet"""
        schema = [(re.sub('_pedsnet', '', schema_path['schema']) + """_3dot1_pcornet"""),
                  (re.sub('_pedsnet', '', schema_path['schema']) + """_3dot1_start2001_pcornet""")]
        # endregion

        # region connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
        # endregion

        # region Check if there is already a configuration file
        # if os.path.isfile(configfile_name):
        # delete the file
        # os.remove(configfile_name)
        # endregion

        return conn + ',' + schema

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

# region Disconnect
def disconnect(cur):
    cur.close()

# endregion
