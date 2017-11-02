from base import Pedsnet_base, Pcornet_base
from sqlalchemy import Column, Integer, String, Numeric, Date, TIMESTAMP, func
from sqlalchemy.sql.expression import case, cast
from sqlalchemy.ext.hybrid import hybrid_property


class Person(Pedsnet_base):
    __tablename__ = 'person'
    # placeholder schema until actual schema known
    __table_args__ = {'schema': 'pedsnet_schema'}
    birth_datetime = Column(TIMESTAMP(False))
    care_site_id = Column(Integer, nullable=False)
    day_of_birth = Column(Integer)
    ethnicity_concept_id = Column(Integer, nullable=False)
    ethnicity_source_concept_id = Column(Integer, nullable=False)
    ethnicity_source_value = Column(String(256))
    gender_concept_id = Column(Integer, nullable=False)
    gender_source_concept_id = Column(Integer, nullable=False)
    gender_source_value = Column(String(256))
    language_concept_id = Column(Integer, nullable=False)
    language_source_concept_id = Column(Integer, nullable=False)
    language_source_value = Column(String(256))
    location_id = Column(Integer)
    month_of_birth = Column(Integer)
    person_id = Column(Integer, primary_key=True, nullable=False)
    person_source_value = Column(String(256))
    pn_gestational_age = Column(Numeric(20, 5))
    provider_id = Column(Integer)
    race_concept_id = Column(Integer, nullable=False)
    race_source_concept_id = Column(Integer, nullable=False)
    race_source_value = Column(String(256))
    year_of_birth = Column(Integer, nullable=False)
    ethnicity_concept_name = Column(String(512))
    ethnicity_source_concept_name = Column(String(512))
    gender_concept_name = Column(String(512))
    gender_source_concept_name = Column(String(512))
    language_concept_name = Column(String(512))
    language_source_concept_name = Column(String(512))
    race_concept_name = Column(String(512))
    race_source_concept_name = Column(String(512))
    site = Column(String(32))
    site_id = Column(Integer)

    @hybrid_property
    def birth_date(self):
        # create birth date from year, month, and day columns
        # ensure month and day are two digits
        # python version
        year = str(self.year_of_birth)
        month = str(self.month_of_birth)
        day = str(self.day_of_birth)

        if month != "":
            month = "01"
        else:
            month = month.zfill(2)

        if day == "":
            day = "01"
        else:
            day = day.zfill(2)

        return year + "-" + month + "-" + day

    @birth_date.expression
    # create birth date from year, month, and day columns
    # ensure month and day are two digits
    # sql version (can't use any database specific functions)
    def birth_date(cls):
        year = cast(cls.year_of_birth, String)
        month = cast(cls.month_of_birth, String)
        day = cast(cls.day_of_birth, String)

        month = case([(month == "", "01")],
                     else_=case([(func.length(month) == 1, "0" + month)], else_=month))
        day = case([(day == "", "01")],
                   else_=case([(func.length(day) == 1, "0" + day)], else_=day))

        return year + "-" + month + "-" + day

    @hybrid_property
    # give time portion of birth datetime column
    # python version
    def birth_time(self):
        return str(self.birth_datetime.strftime('%H:%M'))

    @birth_time.expression
    # give time portion of birth datetime column
    # sql version (can't use any database specific functions)
    def birth_time(cls):
        hour = cast(func.extract("hour", cls.birth_datetime), String)
        minute = cast(func.extract("minute", cls.birth_datetime), String)

        hour = case([(func.length(hour) == 1, "0" + hour)], else_=hour)
        minute = case([(func.length(minute) == 1, "0" + minute)], else_=minute)
        return hour + ":" + minute

    def __init__(self, birth_datetime, care_site_id, day_of_birth,
                 ethnicity_concept_id, ethnicity_source_concept_id,
                 ethnicity_source_value, gender_concept_id,
                 gender_source_concept_id, gender_source_value,
                 language_concept_id, language_source_concept_id,
                 language_source_value, location_id, month_of_birth,
                 person_id, person_source_value, pn_gestational_age,
                 provider_id, race_concept_id, race_source_concept_id,
                 race_source_value, year_of_birth, ethnicity_concept_name,
                 ethnicity_source_concept_name, gender_concept_name,
                 gender_source_concept_name, language_concept_name,
                 language_source_concept_name, race_concept_name,
                 race_source_concept_name, site, site_id):

        self.birth_datetime = birth_datetime
        self.care_site_id = care_site_id
        self.day_of_birth = day_of_birth
        self.ethnicity_concept_id = ethnicity_concept_id
        self.ethnicity_source_concept_id = ethnicity_source_concept_id
        self.ethnicity_source_value = ethnicity_source_value
        self.gender_concept_id = gender_concept_id
        self.gender_source_concept_id = gender_source_concept_id
        self.gender_source_value = gender_source_value
        self.language_concept_id = language_concept_id
        self.language_source_concept_id = language_source_concept_id
        self.language_source_value = language_source_value
        self.location_id = location_id
        self.month_of_birth = month_of_birth
        self.person_id = person_id
        self.person_source_value = person_source_value
        self.pn_gestational_age = pn_gestational_age
        self.provider_id = provider_id
        self.race_concept_id = race_concept_id
        self.race_source_concept_id = race_source_concept_id
        self.race_source_value = race_source_value
        self.year_of_birth = year_of_birth
        self.ethnicity_concept_name = ethnicity_concept_name
        self.ethnicity_source_concept_name = ethnicity_source_concept_name
        self.gender_concept_name = gender_concept_name
        self.gender_source_concept_name = gender_source_concept_name
        self.language_concept_name = language_concept_name
        self.language_source_concept_name = language_source_concept_name
        self.race_concept_name = race_concept_name
        self.race_source_concept_name = race_source_concept_name
        self.site = site
        self.site_id = site_id

    def __repr__(self):
        return "Person - '%s': " \
               "\n\tBirth date: '%s'" \
               "\n\tGender: '%s'" \
               "\n\tEthnicity: '%s'" \
               "\n\tLanguage: '%s'" \
               "\n\tRace: '%s'" \
               "\n\tSite: '%s'" \
               % \
               (self.person_id, self.birth_datetime, self.gender_source_value,
                self.ethnicity_source_value, self.language_source_value,
                self.race_source_value, self.site)


class Demographic(Pcornet_base):
    __tablename__ = 'demographic'
    # placeholder schema until actual schema known
    __table_args__ = {'schema': 'pcornet_schema'}
    patid = Column(String(256), primary_key=True, nullable=False)
    birth_date = Column(Date)
    birth_time = Column(String(5))
    sex = Column(String(2))
    hispanic = Column(String(2))
    race = Column(String(2))
    biobank_flag = Column(String(1))
    raw_sex = Column(String(256))
    raw_hispanic = Column(String(256))
    raw_race = Column(String(256))
    site = Column(String(32), nullable=False)
    gender_identity = Column(String(2))
    raw_gender_identity = Column(String(256))
    sexual_orientation = Column(String(2))
    raw_sexual_orientation = Column(String(256))

    def __init__(self, patid, birth_date, birth_time, sex,
                 hispanic, race, biobank_flag, raw_sex,
                 raw_hispanic, raw_race, site, gender_identity,
                 raw_gender_identity, sexual_orientation,
                 raw_sexual_orientation):
        self.patid = patid
        self.birth_date = birth_date
        self.birth_time = birth_time
        self.sex = sex
        self.hispanic = hispanic
        self.race = race
        self.biobank_flag = biobank_flag
        self.raw_sex = raw_sex
        self.raw_hispanic = raw_hispanic
        self.raw_race = raw_race
        self.site = site
        self.gender_identity = gender_identity
        self.raw_gender_identity = raw_gender_identity
        self.sexual_orientation = sexual_orientation
        self.raw_sexual_orientation = raw_sexual_orientation

    def __repr__(self):
        return "Person - '%s': " \
               "\n\tBirth date: '%s'" \
               "\n\tSex: '%s'" \
               "\n\tRace: '%s'" \
               "\n\tSite: '%s'" \
               % \
               (self.patid, self.birth_date, self.sex,
                self.race, self.site)
