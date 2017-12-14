# region import
from odo import odo
from sqlalchemy.sql.expression import bindparam
from base import *
from celery_create import celery
from enrollment import ObservationPeriod, Enrollment


# endregion

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


@celery.task
def enrollment_etl(config):
    # set up
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
    # endregion

    odo(observation_period, Enrollment.__table__,
        dshape='var * {patid: string, enr_start_date: date, enr_end_date: date, site: string, chart: String, '
               'enr_basis: String} '
        )
    # close session
    pedsnet_session.close()
