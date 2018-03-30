from __future__ import print_function
from sqlalchemy.orm import aliased
from sqlalchemy.sql.expression import case, cast, and_, bindparam
from sqlalchemy.sql.functions import coalesce
from sqlalchemy import String
from demographics import Person, Demographic
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
    Person.__table__.schema = pedsnet_schema
    pedsnet_engine = create_pedsnet_engine(connection)
    pedsnet_session = create_pedsnet_session(pedsnet_engine)
    return pedsnet_session


def init_pcornet(connection):
    pcornet_schema = connection.pcornet_schema
    # override the placeholder schemas on the tables
    Demographic.__table__.schema = pcornet_schema
    ValueSetMap.__table__.schema = pcornet_schema
    create_pcornet_engine(connection)

class Command(BaseCommand):
    help = "Run ETL for Demographics"

    def handle(self, *args, **options):
        # set up
        config = get_config()
        if config is None:
            raise CommandError('Unable to process configuration file p_to_p.yml')
        
        connection = get_connection(config)
        pedsnet_session = init_pedsnet(connection)
        init_pcornet(connection)

        # multiple aliases for pedsnet_pcornet_valueset_map
        # to allow the three named joins
        gender_value_map = aliased(ValueSetMap)
        ethnicity_value_map = aliased(ValueSetMap)
        race_value_map = aliased(ValueSetMap)

        # extract the data from the person table
        person = pedsnet_session.query(Person.person_id,
                                   Person.birth_date,
                                   Person.birth_time,
                                   coalesce(gender_value_map.target_concept, 'OT'),
                                   coalesce(ethnicity_value_map.target_concept, 'OT'),
                                   coalesce(race_value_map.target_concept, 'OT'),
                                   bindparam("biobank_flag", "N"),
                                   Person.gender_source_value,
                                   Person.ethnicity_source_value,
                                   Person.race_source_value,
                                   Person.site,
                                   bindparam("gender_identity", None),
                                   bindparam("raw_gender_identity", None),
                                   bindparam("sexual_orientation", None),
                                   bindparam("raw_sexual_orientation", None)
                                   ). \
            outerjoin(gender_value_map,
                  and_(gender_value_map.source_concept_class == 'Gender',
                       case([(and_(Person.gender_concept_id == None,
                                   gender_value_map.source_concept_id == None), True)],
                            else_=cast(Person.gender_concept_id, String(200)) ==
                                  gender_value_map.source_concept_id))). \
            outerjoin(ethnicity_value_map,
                  and_(ethnicity_value_map.source_concept_class == 'Hispanic',
                       case([(and_(Person.ethnicity_concept_id == None,
                                   ethnicity_value_map.source_concept_id == None), True)],
                            else_=cast(Person.ethnicity_concept_id, String(200)) ==
                                  ethnicity_value_map.source_concept_id))). \
            outerjoin(race_value_map,
                  and_(race_value_map.source_concept_class == 'Race',
                       case([(and_(Person.race_concept_id == None,
                                   race_value_map.source_concept_id == None), True)],
                            else_=cast(Person.race_concept_id,
                                       String(200)) == race_value_map.source_concept_id))).all()

        # transform data to pcornet names and types
        # load to demographic table
        odo(person, Demographic.__table__,
            dshape='var * {patid: string, birth_date: date, birth_time: string, sex: string,'
               'hispanic: string, race: string, biobank_flag: string, raw_sex: string,'
               'raw_hispanic: string, raw_race:string, site: string, gender_identity: string,'
               'raw_gender_identity: string, sexual_orientation: string, raw_sexual_orientation: string}'
            )
        # close session
        pedsnet_session.close()
    
        # output result
        self.stdout.ending = ''
        print('Comptleted ', end='', file=self.stdout)
        print('successfully', end='', file=self.stdout)
