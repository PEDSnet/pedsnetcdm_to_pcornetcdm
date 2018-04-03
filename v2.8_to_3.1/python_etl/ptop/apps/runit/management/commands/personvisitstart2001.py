from base import Pcornet_base
from sqlalchemy import Column, Integer


class PersonVisit(Pcornet_base):
    __tablename__ = 'person_visit_start2001'
    # placeholder schema until actual schema known
    __table_args__ = {'schema': 'pcornet_schema'}
    person_id = Column(Integer, nullable=False)
    visit_id = Column(Integer, primary_key=True, nullable=False)

    def __init__(self, person_id, visit_id):
        self.person_id = person_id
        self.visit_id = visit_id

    def __repr__(self):
        return "Person Id - '%s': " \
               "\n\tVisit Id: '%s'" \
               % \
               (self.person_id, self.visit_id)
