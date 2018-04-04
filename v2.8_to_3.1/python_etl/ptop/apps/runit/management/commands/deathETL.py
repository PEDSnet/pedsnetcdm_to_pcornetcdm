from __future__ import print_function
from sqlalchemy.orm import aliased
from sqlalchemy.sql.expression import cast, and_, bindparam, exists
from sqlalchemy.sql.functions import coalesce, min
from sqlalchemy import String
from death import DeathPedsnet, DeathPcornet, DeathCause
from demographics import Demographic, Person
from valuesetmap import ValueSetMap
from personvisitstart2001 import PersonVisit
from base import *
from odo import odo
from django.core.management.base import BaseCommand, CommandError
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
    DeathPedsnet.__table__.schema = pedsnet_schema
    Person.__table__.schema = pedsnet_schema
    pedsnet_engine = create_pedsnet_engine(connection)
    pedsnet_session = create_pedsnet_session(pedsnet_engine)
    return pedsnet_session


def init_pcornet(connection):
    pcornet_schema = connection.pcornet_schema
    # override the placeholder schemas on the tables

    DeathPcornet.__table__.schema = pcornet_schema
    DeathCause.__table__.schema = pcornet_schema
    Demographic.__table__.schema = pcornet_schema
    ValueSetMap.__table__.schema = pcornet_schema
    PersonVisit.__table__.schema = pcornet_schema
    create_pcornet_engine(connection)


class Command(BaseCommand):
    help = "Run ETL for Death"

    def handle(self, *args, **options):
        # set up
        config = get_config()
        if config is None:
            raise CommandError('Unable to process configuration file p_to_p.yml')

        connection = get_connection(config)
        pedsnet_session = init_pedsnet(connection)
        init_pcornet(connection)

        pedsnet_pcornet_valueset_map = aliased(ValueSetMap)

        # extract the data from the death table
        death_pedsnet = pedsnet_session.query(DeathPedsnet.death_date,
                                              coalesce(pedsnet_pcornet_valueset_map.target_concept, 'OT'),
                                              bindparam("death_match_confidence", None),
                                              bindparam("death_source", "L"),
                                              DeathPedsnet.person_id,
                                              min(DeathPedsnet.site)
                                              ). \
            outerjoin(pedsnet_pcornet_valueset_map,
                      and_(pedsnet_pcornet_valueset_map.source_concept_class == 'Death date impute',
                           cast(DeathPedsnet.death_impute_concept_id, String(200)) ==
                           pedsnet_pcornet_valueset_map.source_concept_id)) \
            .filter(and_(exists().where(DeathPedsnet.person_id == PersonVisit.person_id),
                         DeathPedsnet.death_type_concept_id == 38003569)) \
            .group_by(DeathPedsnet.person_id, DeathPedsnet.death_date,
                      coalesce(pedsnet_pcornet_valueset_map.target_concept, 'OT')) \
            .all()

        # transform data to pcornet names and types
        # load to demographic table
        odo(death_pedsnet, DeathPcornet.__table__,
            dshape='var * {death_date: date, death_date_impute: string, death_match_confidence: string,'
                   'death_source: string, patid:string, site: string}'
            )

        # close session
        pedsnet_session.close()

        # output result
        self.stdout.ending = ''
        print('Death ETL completed successfully', end='', file=self.stdout)
