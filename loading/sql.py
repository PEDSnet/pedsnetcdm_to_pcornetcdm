import click
import requests
import psycopg2
import csv
from config import config
import time


def get_file(directory):
    r = requests.get(
        'https://raw.githubusercontent.com/PEDSnet/pedsnetcdm_to_pcornetcdm/master/v2.6_to_3.1/pedsnet_pcornet_mappings.txt'
    )
    data = csv.reader(r.text.splitlines(), delimiter='|')
    csv_file = csv.writer(open(directory + 'concept_map.csv', 'wb'))
    csv_file.writerows(data)


def connect():
    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters
        params = config('db')
        schema = config('schema')
        directory = config('path')

        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)

        # create a cursor
        cur = conn.cursor()
        cur.statusmessage

        """""
        # execute a statement
        print('PostgreSQL database version:')
        cur.execute('SELECT version()')

        # display the PostgreSQL database server version
        db_version = cur.fetchone()
        print(db_version)
        """""

        # set the search pat to the schema
        cur.execute("""SET search_path TO """ + schema + """;""")
        cur.execute("""SHOW search_path;""")
        search_path = cur.fetchall()
        cur.statusmessage
        print search_path
        time.sleep(0.1)

        if not cur.execute("""SELECT EXISTS (
                                SELECT 1
                                FROM   pg_tables
                                WHERE  schemaname = 'schema_name'
                                AND    tablename = 'table_name'
                                );"""):

            # create table
            try:
                cur.execute(open(directory + 'create_map.sql', 'r').read())
                cur.statusmessage
            except (Exception, psycopg2.OperationalError) as error:
                print(error)
            print 'table created'
            conn.commit()
        else:
            # show table in schema
            cur.execute("""SELECT tablename as table from pg_tables where schemaname = \'""" + schema + """\'""")
            rows = cur.fetchall()
            for row in rows:
                print row

        # import the file to the database
        f = open(directory + 'concept_map.csv', 'r')
        cur.copy_from(f, schema+".cz_omop_pcornet_concept_map", columns=(
            "target_concept", "source_concept_class", "source_concept_id", "value_as_concept_id",
            "concept_description"),
                      sep=",")
        cur.statusmessage
        conn.commit()

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
    connect()
