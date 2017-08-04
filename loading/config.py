from configparser import ConfigParser


def config(info):
    # create a parser
    parser = ConfigParser()
    filename = 'database.ini'
    # read config file
    parser.read(filename)
    if info == 'db':
        # get the section, sefault to postgresql
        db = {}
        if parser.has_section('postgresql'):
            params = parser.items('postgresql')
            for param in params:
                db[param[0]] = param[1]
        else:
            raise Expection('Section {0} not found in the {1} file'.format(section, filename))
        return db
    if info == 'path':
        # get the section, sefault to postgresql
        directory = {}
        if parser.has_section('data'):
            params = parser.items('data')
            for param in params:
                directory[param[0]] = param[1]
        else:
            raise Expection('Section {0} not found in the {1} file'.format(section, filename))
        return directory
    if info == 'schema':
        # get the section, sefault to postgresql
        schema = {}
        if parser.has_section('schema'):
            params = parser.items('schema')
            for param in params:
                schema[param[0]] = param[1]
        else:
            raise Expection('Section {0} not found in the {1} file'.format(section, filename))
        return schema

