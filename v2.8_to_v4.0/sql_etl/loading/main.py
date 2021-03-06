# region import
import ConfigParser
import click
import os
import process
import shutil

# endregion

# region file names
configfile_name = "database.ini"
temp="scripts/temp/"

# endregion

@click.command()
@click.option('--pwprompt', '-p', is_flag=True, default=False,
              help='Prompt for database password')
@click.option('--searchpath', '-s', help='Schema search path in database.ex. stlouis_pcornet')
@click.option('--user', '-u', default=False, help='Database username')
@click.option('--database', '-d', default=False,
              help='Database in wich the mapping file to be loaded ex. pedsnet_dcc_vxx')
@click.option('--host', '-h', default=False, help='The Server name ex. dev01')
@click.option('--options', '-o', default=False, help='pipeline \ntruncate \netl \nddl \nupdate_valueset')
@click.option('--harvest', '-H', required=False, help='harvest refresh date in following formatt yyyy-mm-dd')
@click.option('--testscript', '-ts', required=False, type=click.File('rb'), help='Run single table at a time')
def cli(searchpath, pwprompt, user, database, host, options, harvest, testscript):
    """This tool is used to load the data"""

    # region Option map
    option_map = {
        'pipeline': process.pipeline_full,
        'etl': process.etl_only,
        'truncate': process.truncate_fk,
        'ddl': process.ddl_only,
        'update_map': process.update_valueset,
        'test_script': process.test_script
    }
    # endregion

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

    if not options:
        options = click.prompt('Process Options: \tpipeline \n\t\tetl \n\t\ttruncate \n\t\tddl \n\t\tupdate_map \n')

    if harvest:
        process.harvest_date_refresh(harvest)

    if testscript:
        test_scripr_file = testscript
        if os.path.exists(temp):
            f = open(os.path.join(temp, 'temp.sql'),'wb')
            f.writelines(test_scripr_file)
    # endregion

    # region config file
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
    # endregion

    # region Process Option
    global pipe
    option_map[options]()
    # endregion


# endregion


if __name__ == '__main__':
    cli()
