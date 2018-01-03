# region Imports
import os
import shutil
import requests
import re
import glob
import fileinput

# endregion

# region filenames
csv_concept = "data/concept_map.csv"
create_table_script = "scripts/ddl_scripts/create_table.sql"
site_col_file = "scripts/ddl_scripts/site_col.sql"
privileges = "scripts/ddl_scripts/privileges.sql"
alt_owner_file = "scripts/ddl_scripts/alter_tbl_owner.sql"
trunc = "scripts/ddl_scripts/trunc_fk_idx.sql"
etl_temp_files = "scripts/etl_scripts_temp/"
etl_files ="scripts/etl_scripts/"

# endregion

# region create valueset map
def create_table(schema):
    """
    create tables in the PostgreSQL database in specified schema
    """
    for line in fileinput.input(create_table_script, inplace=1, backup='.bak'):
        line = re.sub('EXISTS .*?\.', "EXISTS " + schema + ".", line.rstrip())
        print(line)
    with open(create_table_script, 'r') as valueset_file:
        commands = valueset_file.read()
    return commands


# endregion

# region Schema Creation
def create_schema(schema):
    """creates schema if not exists"""
    command = """CREATE SCHEMA IF NOT EXISTS """ + schema + """ AUTHORIZATION pcor_et_user;
                 GRANT USAGE ON SCHEMA """ + schema + """ TO pcornet_sas;
                 GRANT ALL ON SCHEMA """ + schema + """ TO dcc_owner;
                 GRANT ALL ON SCHEMA """ + schema + """ TO pcor_et_user;
                 """
    return command


# endregion

# region create DDL
def dll():
    """Creates dll for pcornet"""
    try:
        dll_url = 'http://data-models-sqlalchemy.research.chop.edu/pcornet/3.1.0/ddl/postgresql/tables'
        dll_script = requests.get(dll_url).text
        return dll_script
    except (Exception, requests.ConnectionError) as e:
        print(e)


# endregion

# region Alter site column
def site_col(schema):
    """This function alters the table and creates the site columns"""
    # Replace variables in file
    for line in fileinput.input(site_col_file, inplace=1, backup='.bak'):
        line = re.sub('table .*?\.', "table " + schema + ".", line.rstrip())
        print(line)
    with open(site_col_file, 'r') as site_file:
        alter_site_col = site_file.read()
    return alter_site_col


# endregion

# region Set the privileges
def permission(schema):
    """This function sets up the permissions to the schemas"""
    for line in fileinput.input(privileges, inplace=1, backup='.bak'):
        line = re.sub('SCHEMA .*?\ TO', "SCHEMA " + schema + " TO", line.rstrip())
        print(line)
    with open(privileges, 'r') as perm_file:
        privilege = perm_file.read()
    return privilege


# endregion

# region Alter table owner
def owner(schema):
    """This function returns the sql script to change the owner of all schemas"""
    with open(alt_owner_file, 'r') as owner_file:
        alter_owner = owner_file.read()
    return alter_owner + "select alter_tbl_owner('" + schema + "')"


# endregion

# region Truncate All tables in schema and remove FK's
def truncateqry(schema):
    command = """SELECT truncate_schema('""" + schema + """');"""
    return command


# endregion

# region ETL Scripts Modify
def get_etl_ready(schema):
    # remove all the temp file from the directory etl_scripts
    if os.path.exists(etl_temp_files):
        shutil.rmtree(etl_temp_files)
    shutil.copytree(etl_files, etl_temp_files)

    for file in glob.glob(os.path.join(etl_temp_files, '*.sql')):
        with open(file, 'r') as f:
            content = f.read()
            content = content.replace('SITE', schema)
            f.close()
        with open(file, 'w') as f:
            f.write(content)
# endregion
