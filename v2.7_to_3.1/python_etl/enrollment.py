# region imports
#from base import Pedsnet_base, Pcornet_base
from base import *
from sqlalchemy import Column, Integer, String, Date, TIMESTAMP


# endregion

class ObservationPeriod(Pedsnet_base):
    __tablename__ = 'observation_period'
    # placeholder schema until actual schema known
    __table_args__ = {'schema': 'pedsnet_schema'}

    # region columns
    observation_period_end_date = Column(Date)
    observation_period_end_time = Column(TIMESTAMP(False))
    observation_period_start_date = Column(Date)
    observation_period_start_time = Column(TIMESTAMP(False))
    period_type_concept_id = Column(Integer, nullable=False)
    period_type_concept_name = Column(String(512))
    site = Column(String(32))
    site_id = Column(Integer)
    observation_period_id = Column(Integer, primary_key=True, nullable=False)
    person_id = Column(Integer)

    # endregion

    # region Initialize
    def __init__(self, observation_period_end_date, observation_period_end_time,
                 observation_period_start_date, observation_period_start_time,
                 period_type_concept_id, period_type_concept_name, site, site_id,
                 observation_period_id, person_id):
        self.observation_period_end_date = observation_period_end_date
        self.observation_period_end_time = observation_period_end_time
        self.observation_period_start_date = observation_period_start_date
        self.observation_period_start_time = observation_period_start_time
        self.period_type_concept_id = period_type_concept_id
        self.period_type_concept_name = period_type_concept_name
        self.observation_period_id = observation_period_id
        self.person_id = person_id
        self.site = site
        self.site_id = site_id

    # endregion

    def __repr__(self):
        return "Observation period Id - '%s': " \
               "\n\tObservation period start date: '%s'" \
               "\n\tObservation period end date: '%s'" \
               "\n\tSite: '%s'" \
               % \
               (self.observation_period_id, self.observation_period_start_date, self.observation_period_end_date, self.site)


class Enrollment(Pcornet_base):
    __tablename__ = 'enrollment'
    # placeholder schema until actual schema known
    __table_args__ = {'schema': 'pcornet_schema'}

    # region columns
    patid = Column(String(256), primary_key=True, nullable=False)
    enr_end_date = Column(Date)
    enr_start_date = Column(Date)
    chart = Column(String(1), default='Y')
    enr_basis = Column(String(1), default='E')
    site = Column(String(32), nullable=False)

    # endregion

    # region Initialize
    def __init__(self, patid, enr_end_date, enr_start_date, enr_basis, chart, site):
        self.patid = patid
        self.enr_end_date = enr_end_date
        self.enr_start_date = enr_start_date
        self.enr_basis = enr_basis
        self.chart = chart
        self.site = site

    # endregion

    def __repr__(self):
        return "Pat id - '%s': " \
               "\n\tenr end date: '%s'" \
               "\n\tenr start date: '%s'" \
               "\n\tchart: '%s'" \
               "\n\tenr_basis: '%s'" \
               "\n\tSite: '%s'" \
               % \
               (self.patid, self.enr_end_date, self.enr_start_date, self.chart, self.enr_basis, self.chart)
