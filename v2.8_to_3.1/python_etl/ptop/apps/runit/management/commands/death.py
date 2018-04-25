from base import Pedsnet_base, Pcornet_base
from sqlalchemy import Column, Integer, String, Numeric, Date, TIMESTAMP, Float


class DeathPedsnet(Pedsnet_base):
    __tablename__ = 'death'
    # placeholder schema until actual schema known
    __table_args__ = {'schema': 'pedsnet_schema'}

    cause_concept_id = Column(Integer)
    cause_source_concept_id = Column(Integer)
    cause_source_value = Column(String(256))
    death_date = Column(Date, nullable=False)
    death_datetime = Column(TIMESTAMP(False), nullable=False)
    death_impute_concept_id = Column(Integer, nullable=False)
    death_type_concept_id = Column(Integer, nullable=False)
    death_age_in_months = Column(Float(Precision=64))
    cause_concept_name = Column(String(512))
    cause_source_concept_name = Column(String(512))
    death_impute_concept_name = Column(String(512))
    death_type_concept_name = Column(String(512))
    site = Column(String(32))
    death_cause_id = Column(Integer, primary_key=True, nullable=False)
    site_id = Column(Integer)
    person_id = Column(Integer, nullable=False)

    def __init__(self, cause_concept_id, cause_source_concept_id, cause_source_value,
                 death_date, death_datetime, death_impute_concept_id, death_type_concept_id,
                 death_age_in_months, cause_concept_name, cause_source_concept_name,
                 death_impute_concept_name, death_type_concept_name, site, death_cause_id,
                 site_id, person_id):
        self.cause_concept_id = cause_concept_id
        self.cause_source_concept_id = cause_source_concept_id
        self.cause_source_value = cause_source_value
        self.death_date = death_date
        self.death_datetime = death_datetime
        self.death_impute_concept_id = death_impute_concept_id
        self.death_type_concept_id = death_type_concept_id
        self.death_age_in_months = death_age_in_months
        self.cause_concept_name = cause_concept_name
        self.cause_source_concept_name = cause_source_concept_name
        self.death_impute_concept_name = death_impute_concept_name
        self.death_type_concept_name = death_type_concept_name
        self.site = site
        self.death_cause_id = death_cause_id
        self.site_id = site_id
        self.person_id = person_id

    def __repr__(self):
        return "Death Id - '%s': " \
               "\n\tPerson Id: '%s'" \
               "\n\tDeath Date: '%s'" \
               "\n\tDeath Age: '%s'" \
               "\n\tCause: '%s'" \
               "\n\tSite: '%s'" \
               % \
               (self.death_cause_id, self.person_id, self.death_datetime,
                self.death_age_in_months, self.cause_concept_name, self.site)


class DeathPcornet(Pcornet_base):
    __tablename__ = 'death'
    # placeholder schema until actual schema known
    __table_args__ = {'schema': 'pcornet_schema'}
    death_date = Column(Date)
    death_date_impute = Column(String(2))
    death_match_confidence = Column(String(2))
    death_source = Column(String(2), nullable=False)
    patid = Column(String(256), primary_key=True, nullable=False)
    site = Column(String(32), nullable=False)

    def __init__(self, death_date, death_date_impute, death_match_confidence,
                 death_source, patid, site):
        self.death_date = death_date
        self.death_date_impute = death_date_impute
        self.death_match_confidence = death_match_confidence
        self.death_source = death_source
        self.patid = patid
        self.site = site

    def __repr__(self):
        return "Person - '%s': " \
               "\n\tDeath date: '%s'" \
               "\n\tSource: '%s'" \
               "\n\tSite: '%s'" \
               % \
               (self.patid, self.death_date, self.death_source, self.site)


class DeathCause(Pcornet_base):
    __tablename__ = 'death_cause'
    # placeholder schema until actual schema known
    __table_args__ = {'schema': 'pcornet_schema'}
    death_cause = Column(String(8), primary_key=True, nullable=False)
    death_cause_code = Column(String(2), primary_key=True, nullable=False)
    death_cause_confidence = Column(String(2))
    death_cause_source = Column(String(2), primary_key=True, nullable=False)
    death_cause_type = Column(String(2), primary_key=True, nullable=False)
    patid = Column(String(256), primary_key=True, nullable=False)
    site = Column(String(32), nullable=False)

    def __init__(self, death_cause, death_cause_code, death_cause_confidence,
                 death_cause_source, death_cause_type, patid, site):
        self.death_cause = death_cause
        self.death_cause_code = death_cause_code
        self.death_cause_confidence = death_cause_confidence
        self.death_cause_source = death_cause_source
        self.death_cause_type = death_cause_type
        self.patid = patid
        self.site = site

    def __repr__(self):
        return "Person - '%s': " \
               "\n\tDeath Cause: '%s'" \
               "\n\tCause Code: '%s'" \
               "\n\tCause Source: '%s'" \
               "\n\tCause Type: '%s'" \
               "\n\tSite: '%s'" \
               % \
               (self.patid, self.death_cause, self.death_cause_code,
                self.death_cause_source, self.death_cause_type, self.site)
