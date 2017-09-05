from config import config
import csv
import requests
import os

csv_concept = "concept_map.csv"
create_table_script = "scripts/create_table.sql"


def get_file(uri):
    if not uri:
        uri = 'https://raw.githubusercontent.com/PEDSnet/pedsnetcdm_to_pcornetcdm/master/v2.6_to_3.1/pedsnet_pcornet_mappings.txt'
    r = requests.get(uri)
    data = csv.reader(r.text.splitlines(), delimiter='|')
    if not os.path.isfile(csv_concept):
        csv_file = csv.writer(open('concept_map/concept_map.csv', 'wb'))
        csv_file.writerows(data)


def create_table(schema):
    """ create tables in the PostgreSQL database"""

    commands = """CREATE TABLE IF NOT EXISTS """ + schema + """.pedsnet_pcornet_valueset_map (
                target_concept character varying(200),
                source_concept_class character varying(200),
                source_concept_id character varying(200),
                value_as_concept_id character varying(200),
                concept_description character varying(200)
                );

                ALTER TABLE """ + schema + """.pedsnet_pcornet_valueset_map
                OWNER to pcor_et_user;

                GRANT SELECT ON TABLE """ + schema + """.pedsnet_pcornet_valueset_map TO pcornet_sas;

                GRANT SELECT ON TABLE """ + schema + """.pedsnet_pcornet_valueset_map TO peds_staff;

                GRANT ALL ON TABLE """ + schema + """.pedsnet_pcornet_valueset_map TO pcor_et_user;

                GRANT ALL ON TABLE """ + schema + """.pedsnet_pcornet_valueset_map TO dcc_owner; """
    with open(create_table_script, 'wb') as f:
        f.writelines(commands)
    return commands


def create_schema(schema):
    """creates schema if not exists"""

    command = """CREATE SCHEMA IF NOT EXISTS """ + schema + """ AUTHORIZATION pcor_et_user;
                 GRANT USAGE ON SCHEMA """ + schema + """ TO dcc_owner;
                 GRANT ALL ON schema """ + schema + """ TO dcc_owner;"""
    return command
