FROM golang:1.11


RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates

RUN update-ca-certificates

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' >> /etc/apt/sources.list
RUN wget --no-check-certificate -O /tmp/postgresqlkey.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key add /tmp/postgresqlkey.asc

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libprotobuf-dev \
      libleveldb-dev \
      libgeos-dev \
      postgresql-client-11 \
      python3-pip \
 && ln -s /usr/lib/libgeos_c.so /usr/lib/libgeos.so \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip
RUN pip3 install -U setuptools

RUN go get github.com/omniscale/imposm3 \
 && go install github.com/omniscale/imposm3/cmd/imposm

RUN git clone https://github.com/gbb/par_psql && \
    cd par_psql && ./install.sh

# Purge no longer needed packages to keep image small.
# Protobuf and LevelDB dependencies cannot be removed
# because they are dynamically linked.
RUN apt-get purge -y --auto-remove \
      g++ gcc libc6-dev make git \
      && rm -rf /var/lib/apt/lists/*

ADD . /osmnames
WORKDIR /osmnames

# RUN pip3 install psycopg2-binary==2.7.7
RUN pip3 install -r requirements.txt.lock

CMD ["./run.py"]
