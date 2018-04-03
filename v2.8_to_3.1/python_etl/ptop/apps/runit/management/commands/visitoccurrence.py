from base import Pedsnet_base
from sqlalchemy import Column, Integer, TIMESTAMP, Date, String, Float


class VisitOccurrence(Pedsnet_base):
    __tablename__ = 'visit_occurrence'
    # placeholder schema until actual schema known
    __table_args__ = {'schema': 'pedsnet_schema'}
    admitting_source_concept_id = Column(Integer)
    admitting_source_value = Column(String(256))
    discharge_to_concept_id = Column(Integer)
    discharge_to_source_value = Column(String(256))
    visit_concept_id = Column(Integer, nullable=False)
    visit_end_date = Column(Date)
    visit_end_datetime = Column(TIMESTAMP(False))
    visit_source_concept_id = Column(Integer)
    visit_source_value = Column(String(256))
    visit_start_date = Column(Date, nullable=False)
    visit_start_datetime = Column(TIMESTAMP(False), nullable=False)
    visit_type_concept_id = Column(Integer, nullable=False)
    visit_start_age_in_months = Column(Float(Precision=64))
    admitting_source_concept_name = Column(String(512))
    discharge_to_concept_name = Column(String(512))
    visit_concept_name = Column(String(512))
    visit_source_concept_name = Column(String(512))
    visit_type_concept_name = Column(String(512))
    site = Column(String(32))
    visit_occurrence_id = Column(Integer, primary_key=True, nullable=False)
    site_id = Column(Integer)
    preceding_visit_occurrence_id = Column(Integer)
    person_id = Column(Integer, nullable=False)
    provider_id = Column(Integer)
    care_site_id = Column(Integer)

    def __init__(self, admitting_source_concept_id, admitting_source_value,
                 discharge_to_concept_id, discharge_to_source_value,
                 visit_concept_id, visit_end_date, visit_end_datetime,
                 visit_source_concept_id, visit_source_value, visit_start_date,
                 visit_start_datetime, visit_type_concept_id, visit_start_age_in_months,
                 admitting_source_concept_name, discharge_to_concept_name,
                 visit_concept_name, visit_source_concept_name, visit_type_concept_name,
                 site, visit_occurrence_id, site_id, preceding_visit_occurrence_id,
                 person_id, provider_id, care_site_id):

        self.admitting_source_concept_id = admitting_source_concept_id
        self.admitting_source_value = admitting_source_value
        self.discharge_to_concept_id = discharge_to_concept_id
        self.discharge_to_source_value = discharge_to_source_value
        self.visit_concept_id = visit_concept_id
        self.visit_end_date = visit_end_date
        self.visit_end_datetime = visit_end_datetime
        self.visit_source_concept_id = visit_source_concept_id
        self.visit_source_value = visit_source_value
        self.visit_start_date = visit_start_date
        self.visit_start_datetime = visit_start_datetime
        self.visit_type_concept_id = visit_type_concept_id
        self.visit_start_age_in_months = visit_start_age_in_months
        self.admitting_source_concept_name = admitting_source_concept_name
        self.discharge_to_concept_name = discharge_to_concept_name
        self.discharge_to_concept_name = discharge_to_concept_name
        self.visit_concept_name = visit_concept_name
        self.visit_source_concept_name = visit_source_concept_name
        self.visit_type_concept_name = visit_type_concept_name
        self.site = site
        self.visit_occurrence_id = visit_occurrence_id
        self.site_id = site_id
        self.preceding_visit_occurrence_id = preceding_visit_occurrence_id
        self.person_id = person_id
        self.provider_id = provider_id
        self.care_site_id = care_site_id

    def __repr__(self):
        return "Visit Occurrence Id - '%s': " \
               "\n\tPerson Id: '%s'" \
               "\n\tProvider Id: '%s'" \
               "\n\tStart Date: '%s'" \
               "\n\tEnd Date: '%s'" \
               "\n\tConcept Name: '%s'" \
               "\n\tSource Value: '%s'" \
               "\n\tSite: '%s'" \
               % \
               (self.visit_occurrence_id, self.person_id, self.provider_id,
                self.visit_start_date, self.visit_end_date, self.visit_concept_name,
                self.visit_source_value, self.site)
