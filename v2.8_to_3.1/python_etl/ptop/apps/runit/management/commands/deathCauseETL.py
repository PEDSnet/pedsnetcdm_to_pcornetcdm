from __future__ import print_function
from sqlalchemy.orm import aliased
from sqlalchemy.sql.expression import cast, and_, bindparam
from sqlalchemy.sql.functions import coalesce, min
from sqlalchemy import String, func
from death import DeathPedsnet, DeathPcornet, DeathCause
from demographics import Demographic, Person
from vocabulary import VocabularyConcept
from valuesetmap import ValueSetMap
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
    create_pcornet_engine(connection)


def init_vocab(connection):
    vocab_schema = connection.vocab_schema
    # override the placeholder schemas on the tables
    VocabularyConcept.__table__.schema = vocab_schema
    create_vocab_engine(connection)


class Command(BaseCommand):
    help = "Run ETL for Death Cause"

    def handle(self, *args, **options):
        # set up
        config = get_config()
        if config is None:
            raise CommandError('Unable to process configuration file p_to_p.yml')

        connection = get_connection(config)
        pedsnet_session = init_pedsnet(connection)
        init_pcornet(connection)
        init_vocab(connection)

        pedsnet_pcornet_valueset_map = aliased(ValueSetMap)

        # extract the data from the death table
        death_cause = pedsnet_session.query(DeathPedsnet.person_id,
                                            func.left(DeathPedsnet.cause_source_value, 8),
                                            coalesce(pedsnet_pcornet_valueset_map.target_concept, 'OT'),
                                            bindparam("death_cause_type", "NI"),
                                            bindparam("death_cause_source", "L"),
                                            bindparam("death_cause_confidence", None),
                                            min(DeathPedsnet.site)
                                            ) \
            .join(Demographic, Demographic.patid == cast(DeathPedsnet.person_id, String(256)), ) \
            .join(VocabularyConcept, VocabularyConcept.concept_id == DeathPedsnet.cause_concept_id) \
            .outerjoin(pedsnet_pcornet_valueset_map,
                       and_(pedsnet_pcornet_valueset_map.source_concept_class == 'death cause code',
                            cast(VocabularyConcept.vocabulary_id, String(200)) ==
                            pedsnet_pcornet_valueset_map.source_concept_id)) \
            .filter(and_(DeathPedsnet.cause_source_value != None,
                         DeathPedsnet.cause_source_concept_id != 44814650)) \
            .group_by(DeathPedsnet.person_id, func.left(DeathPedsnet.cause_source_value, 8),
                      coalesce(pedsnet_pcornet_valueset_map.target_concept, 'OT')) \
            .all()

        # transform data to pcornet names and types
        # load to demographic table
        odo(death_cause, DeathCause.__table__,
            dshape='var * {patid: string, death_cause: string, death_cause_code: string,'
                   'death_cause_type: string, death_cause_source:string, '
                   'death_cause_confidence: string, site: string}'
            )

        # close session
        pedsnet_session.close()

        # output result
        self.stdout.ending = ''
        print('Death Cause ETL completed successfully', end='', file=self.stdout)
