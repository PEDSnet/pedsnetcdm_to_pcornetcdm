from base import Pcornet_base
from sqlalchemy import Column, String, ForeignKey
from demographics import Person


class ValueSetMap(Pcornet_base):
    __tablename__ = 'pedsnet_pcornet_valueset_map'
    # placeholder schema until actual schema known
    __table_args__ = {'schema': 'pcornet_schema'}
    target_concept = Column(String(200))
    source_concept_class = Column(String(200))
    source_concept_id = Column(String(200), ForeignKey(Person.gender_concept_id), primary_key=True)
    value_as_concept_id = Column(String(200))
    concept_description = Column(String(200))

    def __init__(self, target_concept, source_concept_class,
                 source_concept_id, value_as_concept_id,
                 concept_description):
        self.target_concept = target_concept
        self.source_concept_class = source_concept_class
        self.source_concept_id = source_concept_id
        self.value_as_concept_id = value_as_concept_id
        self.concept_description = concept_description

    def __repr__(self):
        return "ValueSet: " \
               "\n\tTarget_concept: '%s'" \
               "\n\tSource_concept_class: '%s'" \
               "\n\tSource_concept_id: '%s'" \
               "\n\tValue_as_concept_id: '%s'" \
               "\n\tConcept_description: '%s'" \
               % \
               (self.target_concept, self.source_concept_class,
                self.source_concept_id, self.value_as_concept_i,
                self.concept_description)
