FROM ubuntu:bionic
MAINTAINER Shweta Chavan

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -my wget gnupg

RUN apt-get install -y tzdata

RUN apt-get install wget ca-certificates

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main 9.5" >> /etc/apt/sources.list.d/postgresql.list'

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN apt-get update && apt-get install -y apt-utils git-all libpq-dev graphviz graphviz-dev pkg-config postgresql-10

RUN set -xe \
&& apt-get update \
    && apt-get install -y python-pip python3-pip nano

RUN pip install --upgrade pip \
    && python3 -m pip install virtualenv \
    && python3 -m pip install requests \
    && python3 -m pip install psycopg2 \
    && python3 -m pip install ConfigParser \
    && export LC_ALL=C.UTF-8 \
    && export LANG=C.UTF-8

COPY . /app/

RUN cd /app/ \
    && git clone https://github.com/PEDSnet/pedsnetcdm_to_pcornetcdm.git \
    && cd pedsnetcdm_to_pcornetcdm \
    && git checkout v50_to_v61 \
    && cd v5.0_to_v6.1/sql_etl \
    && python3 -m virtualenv venv \
    && ./venv/bin/activate \
    && python3 -m pip install -r requirements.txt \
    && python3 -m pip install --editable .

#USER normalized
RUN useradd -m -s /bin/bash normalized

RUN mkdir /output

RUN chmod 755 /output

WORKDIR /app/pedsnetcdm_to_pcornetcdm/v5.0_to_v6.1/sql_etl/

ENTRYPOINT ["loading"]
CMD ["--help"]
