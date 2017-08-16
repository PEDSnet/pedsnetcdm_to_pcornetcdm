# pcornet_loading

`loading` is a CLI tool for PCORNet for creating the schema and loading the concept map csv file.

## Usage

### Create Schema and Load concept map file

The command to creates a new schema for a specific site, e.g. `pedsnet_start2001`, and the database, `pedsnet_dcc_vxx` with which to create. 

    loading -u $USER -s $SCHEMA -d $DATABASE -h $SERVER_NAME

Breakdown:

The line creates the config file, connects to the database, creates schema and upload the concept map data.

### TODO

...
