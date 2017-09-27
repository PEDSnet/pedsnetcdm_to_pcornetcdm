# region import
import ConfigParser
import re
import click
import psycopg2
import time
import os
import config
import query
# endregion

configfile_name = "database.ini"


@click.command()
@click.option('--pwprompt', '-p', is_flag=True, default=False,
              help='Prompt for database password')
@click.option('--searchpath', '-s', help='Schema search path in database.ex. stlouis_pcornet')
@click.option('--user', '-u', default=False, help='Database username')
@click.option('--database', '-d', default=False,
              help='Database in wich the mapping file to be loaded ex. pedsnet_dcc_vxx')
@click.option('--host', '-h', default=False, help='The Server name ex. dev01')
def cli(searchpath, pwprompt, user, database, host):
    """This tool is used to load the data"""
    # region verify
    if not user:
        click.echo('Please provide the database username.')
        user = click.prompt('Username', hide_input=False)

    password = None
    if not pwprompt:
        password = click.prompt('Database password', hide_input=True)

    if not host:
        host = click.prompt('server name', hide_input=True)

    if not database:
        database = click.prompt('Database name', hide_input=False)

    if not searchpath:
        searchpath = click.prompt('schema name', hide_input=False)
    # endregion

    # Check if there is already a configuration file
    if os.path.isfile(configfile_name):
        os.remove(configfile_name)

    if not os.path.isfile(configfile_name):
        cfgfile = open(configfile_name, 'w')

        configini = ConfigParser.ConfigParser()
        configini.add_section('postgresql')
        configini.set('postgresql', 'host', host)
        configini.set('postgresql', 'database', database)
        configini.set('postgresql', 'user', user)
        configini.set('postgresql', 'password', password)

        configini.add_section('schema')
        configini.set('schema', 'schema', searchpath)

        configini.write(cfgfile)
        cfgfile.close()

        connect()


def connect():
    '''This function is used to connect to the database and query the database'''
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
        if os.path.isfile(configfile_name):
            # delete the file
            os.remove(configfile_name)
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


if __name__ == '__main__':
    cli()
