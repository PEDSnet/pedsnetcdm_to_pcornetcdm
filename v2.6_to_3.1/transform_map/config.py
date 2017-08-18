import ConfigParser


def config(info):
    filename = 'database.ini'
    # create a parser
    parser = ConfigParser.ConfigParser()
    # read config file
    parser.read(filename)
    # get the section, sefault to postgresql
    if info == 'db':
        db = {}
        if parser.has_section('postgresql'):
            params = parser.items('postgresql')
            for param in params:
                db[param[0]] = param[1]
        else:
            raise Expection('Section {0} not found in the {1} file'.format(section, filename))
        return db
    if info == 'schema':
        schema = {}
        if parser.has_section('schema'):
            params = parser.items('schema')
            for param in params:
                schema[param[0]] = param[1]
        else:
            raise Expection('Section {0} not found in the {1} file'.format(section, filename))
        return schema