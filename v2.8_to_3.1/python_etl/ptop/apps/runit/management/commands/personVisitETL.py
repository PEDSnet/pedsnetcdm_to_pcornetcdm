from __future__ import print_function
from odo import odo
from sqlalchemy import extract
from base import *
from personvisitstart2001 import PersonVisit
from visitoccurrence import VisitOccurrence
from django.core.management.base import BaseCommand, CommandError
import pandas as pd
import os
import yaml


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
    VisitOccurrence.__table__.schema = pedsnet_schema
    pedsnet_engine = create_pedsnet_engine(connection)
    pedsnet_session = create_pedsnet_session(pedsnet_engine)
    return pedsnet_session


def init_pcornet(connection):
    pcornet_schema = connection.pcornet_schema
    # override the placeholder schemas on the tables
    PersonVisit.__table__.schema = pcornet_schema
    create_pcornet_engine(connection)


class Command(BaseCommand):
    help = "Run ETL for PersonVisit"

    def handle(self, *args, **options):
        # set up
        config = get_config()
        if config is None:
            raise CommandError('Unable to process configuration file p_to_p.yml')

        connection = get_connection(config)
        pedsnet_session = init_pedsnet(connection)
        init_pcornet(connection)

        for df in pd.read_sql(pedsnet_session.query(VisitOccurrence.person_id,
                                                    VisitOccurrence.visit_occurrence_id.label('visit_id')) \
                                      .filter(extract('year', VisitOccurrence.visit_start_date) >= 2001).statement,
                              pedsnet_session.bind, chunksize=50000):

            odo(df, PersonVisit.__table__,
                dshape='var * {person_id: int, visit_id: int}'
                )

        # close session
        pedsnet_session.close()

        # ouutput result
        self.stdout.ending = ''
        print('Person Visit ETL completed successfully', end='', file=self.stdout)
