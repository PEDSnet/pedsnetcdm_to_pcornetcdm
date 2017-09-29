SHELL=/bin/bash	# needed for full, non-Posix features (process substitution via `<()`)                                                                                                                    
DB?=none	# Set this on the command line via `make ... DB=thedb` or as an env variable                                                                                                                    
VER?=none	# Set this on the command line via `make ... VER=theversion` or as an env variable                                                                                                              

LOGDIR=logs_create_pcornet

.PHONY: all
all: dcc 

%:
	@if [ "${DB}" == "none" ]; then echo "Invoke as: make -f create_pcornet_tables.Makefile DB=thedb VER=theversion"; false; fi
	@if [ "${VER}" == "none" ]; then echo "Invoke as: make -f create_pcornet_tables.Makefile DB=thedb VER=theversion"; false; fi
	mkdir -p ${LOGDIR}
	cat <(echo SET ROLE pcor_et_user\;) <(curl -s http://data-models-sqlalchemy.research.chop.edu/pcornet/${VER}/ddl/postgresql/tables/) | docker exec -i pedsnet_postgres_1 gosu postgres env PGOPTIONS="-c search_path=${@}_pcornet" psql -a ${DB} >> ${LOGDIR}/$@.log 2>&1
