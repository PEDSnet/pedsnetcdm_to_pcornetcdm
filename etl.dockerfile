#
# DBHi/Ops ETL Project
#
#
#
# https://github.research.chop.edu/cbmi/Ops

FROM postgres

MAINTAINER LeMar Davidson <davidsonl2@email.chop.edu>

RUN apt-get update -y

RUN apt-get upgrade -y

RUN apt-get install -y postfix

ENV DEBIAN_FRONTEND noninteractive

ENV MAILTO davidsonl2@email.chop.edu

ENV APP_NAME etl

RUN mkdir -p /opt/apps/biorc_logstash

CMD ["run"]
