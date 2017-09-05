import ConfigParser
import click
import psycopg2
import time
import os
import config
import query

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

    # Check if there is already a configuration file
    if os.path.isfile(configfile_name):
        # delete the file
        os.remove(configfile_name)
    if not os.path.isfile(configfile_name):
        # Create the configuration file as it doesnt exist yet
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
        # read connection parameters
        params = config.config('db')
        schema_path = config.config('schema')
        # schema = schema_path['schema']+"""_3dot1_pcornet"""
        schema = [schema_path['schema'] + """_3dot1_pcornet""", schema_path['schema'] + """_start2001_pcornet"""]

        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
        # create a cursor
        cur = conn.cursor()

        # Check if there is already a configuration file
        if os.path.isfile(configfile_name):
            # delete the file
            os.remove(configfile_name)

        for schemas in schema:
            # check if the schema exisit
            cur.execute(
                """select exists(select 1 from information_schema.schemata where schema_name = \'""" + schemas + """\');""")
            schema_exist = cur.fetchall()[0]
            print(schema_exist)

            if "True" not in schema_exist:
                cur.execute(query.create_schema(schemas))
                print '% schema created' % schema

            # set the search pat to the schema
            cur.execute("""SET search_path TO """ + schemas + """;""")

            # cur.execute("""SHOW search_path;""")
            # path = cur.fetchall()
            # print(path)
            time.sleep(0.1)

            # create table
            try:
                cur.execute(query.create_table(schemas))
                print(conn.notices)
                conn.commit()

                # import the file to the database
                if os.path.isfile('concept_map/concept_map.csv'):
                    f = open('concept_map/concept_map.csv', 'r')
                    cur.copy_from(f, schemas + ".pedsnet_pcornet_valueset_map", columns=(
                        "target_concept", "source_concept_class", "source_concept_id", "value_as_concept_id",
                        "concept_description"),
                                  sep=",")
                    print(conn.notices)
                    conn.commit()
            except (Exception, psycopg2.OperationalError) as error:
                print(error)
        # close the communication with the PostgreSQL
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
