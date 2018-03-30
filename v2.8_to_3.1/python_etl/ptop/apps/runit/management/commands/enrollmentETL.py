# region import
from __future__ import print_function
from odo import odo
from sqlalchemy.sql.expression import bindparam
from base import *
from enrollment import ObservationPeriod, Enrollment
from django.core.management.base import BaseCommand, CommandError
import os
import yaml
# endregion

def get_config():
    try:
        module_dir = os.path.dirname(__file__)  # get current directory
        file_path = os.path.join(module_dir, 'p_to_p.yml')
        with open(file_path, 'r') as f:
            config = yaml.load(f)
            return config
    except:
        return None


def init_pedsnet(connection):
    pedsnet_schema = connection.pedsnet_schema
    # override the placeholder schemas on the tables
    ObservationPeriod.__table__.schema = pedsnet_schema
    pedsnet_engine = create_pedsnet_engine(connection)
    pedsnet_session = create_pedsnet_session(pedsnet_engine)
    return pedsnet_session


def init_pcornet(connection):
    pcornet_schema = connection.pcornet_schema
    # override the placeholder schemas on the tables
    Enrollment.__table__.schema = pcornet_schema
    create_pcornet_engine(connection)


class Command(BaseCommand):
    help = "Run ETL for Enrollment"

    def handle(self, *args, **options):
        # set up
        config = get_config()
        if config is None:
            raise CommandError('Unable to process configuration file p_to_p.yml')

        connection = get_connection(config)
        pedsnet_session = init_pedsnet(connection)
        init_pcornet(connection)

        observation_period = pedsnet_session.query(ObservationPeriod.person_id,
                                               ObservationPeriod.observation_period_start_date,
                                               ObservationPeriod.observation_period_end_date,
                                               ObservationPeriod.site,
                                               bindparam("chart", 'Y'),
                                               bindparam("enr_basis", 'E')
                                               ).all()

        odo(observation_period, Enrollment.__table__,
            dshape='var * {patid: string, enr_start_date: date, enr_end_date: date, site: string, chart: String, '
               'enr_basis: String} '
        )
        # close session
        pedsnet_session.close()
   
        # ouutput result
        self.stdout.ending = ''
        print('Comptleted ', end='', file=self.stdout)
        print('successfully', end='', file=self.stdout) 
