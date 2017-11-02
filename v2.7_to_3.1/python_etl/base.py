from sqlalchemy.ext.declarative import declarative_base, DeferredReflection
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# defer engine until connection details available
Pedsnet_base = declarative_base(cls=DeferredReflection)
Pcornet_base = declarative_base(cls=DeferredReflection)


# connection details from yml file
class Connection(object):
    def __init__(self, user, password, port, driver, host,
                 pedsnet_database, pcornet_database,
                 pedsnet_schema, pcornet_schema):
        self.user = user
        self.password = password
        self.port = port
        self.driver = driver
        self.host = host
        self.pedsnet_database = pedsnet_database
        self.pcornet_database = pcornet_database
        self.pedsnet_schema = pedsnet_schema
        self.pcornet_schema = pcornet_schema
        self.pedsnet_connect_string = driver + "://" + user + ":" \
                                      + password + "@" + host + ":" + port + "/" + pedsnet_database
        self.pcornet_connect_string = driver + "://" + user + ":" \
                                      + password + "@" + host + ":" + port + "/" + pcornet_database


def get_connection(config):
    connection = Connection(config["db"]["dbuser"], config["db"]["dbpass"],
                            str(config["db"]["dbport"]), str(config["db"]["driver"]),
                            config["db"]["dbhost"], config["db"]["pedsnet_dbname"],
                            config["db"]["pcornet_dbname"], config["db"]["pedsnet_schema"],
                            config["db"]["pcornet_schema"])
    return connection


def get_pedsnet_schema(connection):
    return connection.pedsnet_schema


def get_pcornet_schema(connection):
    return connection.pcornet_schema


def create_pedsnet_engine(connection):
    # create the database engines
    pedsnet_engine = create_engine(connection.pedsnet_connect_string)

    # replace deferred base
    Pedsnet_base.prepare(pedsnet_engine)

    # bind the tables to the engines
    Pedsnet_base.metadata.bind = pedsnet_engine

    return pedsnet_engine


def create_pcornet_engine(connection):
    # create the database engines
    pcornet_engine = create_engine(connection.pcornet_connect_string)

    # replace deferred base
    Pcornet_base.prepare(pcornet_engine)

    # bind the tables to the engine
    Pcornet_base.metadata.bind = pcornet_engine

    return pcornet_engine


# create pedsnet session
def create_pedsnet_session(pedsnet_engine):
    Session = sessionmaker(bind=pedsnet_engine)
    session = Session()
    return session


# create pcornet session
def create_pcornet_session(pcornet_engine):
    Session = sessionmaker(bind=pcornet_engine)
    session = Session()
    return session
