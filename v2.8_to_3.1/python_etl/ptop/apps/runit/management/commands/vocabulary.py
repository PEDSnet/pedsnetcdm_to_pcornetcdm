from base import Vocab_base
from sqlalchemy import Column, String, Integer, Date


class VocabularyConcept(Vocab_base):
    __tablename__ = 'concept'
    # placeholder schema until actual schema known
    __table_args__ = {'schema': 'vocab_schema'}
    concept_class_id = Column(String(50), nullable=False)
    concept_code = Column(String(255), nullable=False)
    concept_id = Column(Integer, primary_key=True, nullable=False)
    concept_level = Column(Integer)
    concept_name = Column(String(512), nullable=False)
    domain_id = Column(String(20), nullable=False)
    invalid_reason = Column(String(1))
    standard_concept = Column(String(1), nullable=False)
    valid_start_date = Column(Date, nullable=False)
    vocabulary_id = Column(String(20), nullable=False)

    def __init__(self, concept_class_id, concept_code, concept_id,
                 concept_level, concept_name, domain_id, invalid_reason,
                 standard_concept, valid_start_date, vocabulary_id):
        self.concept_class_id = concept_class_id
        self.concept_code = concept_code
        self.concept_id = concept_id
        self.concept_level = concept_level
        self.concept_name = concept_name
        self.domain_id = domain_id
        self.invalid_reason = invalid_reason
        self.standard_concept = standard_concept
        self.valid_start_date = valid_start_date
        self.vocabulary_id = vocabulary_id

    def __repr__(self):
        return "Vocabulary Concept: " \
               "\n\tConcept Id: '%s'" \
               "\n\tConcept Code: '%s'" \
               "\n\tConcept Name: '%s'" \
               "\n\tValid Start Date: '%s'" \
               "\n\tVocabulary Id: '%s'" \
               % \
               (self.concept_id, self.concept_code,
                self.concept_name, self.valid_start_date,
                self.vocabulary_id)
