#Latest in this case refers to 16.04LTS
FROM ubuntu:latest

#Enviroment vars
ENV JAVA_HOME /usr/lib/jvm/java-9-oracle
ENV JRE_HOME ${JAVA_HOME}/jre
ENV GRADLE_VERSION=4.6
ENV GRADLE_HOME=/opt/gradle/gradle-$GRADLE_VERSION
ENV PATH=$PATH:$GRADLE_HOME/bin

#Skip any interactive apt-get related stuff
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /tmp

#Update and install general ubuntu related utils
RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties unzip

#PostgreSQL
#RUN apt-get install -y postgresql postgresql-contrib libpq-dev
#The following is based on https://hub.docker.com/r/partlab/ubuntu-postgresql/~/dockerfile/
ENV PG_VERSION 9.5
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
#    echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' \
#      | tee /etc/apt/sources.list.d/postgresql.list && \
#    apt-get update && \
#    apt-get install -y -q --no-install-recommends \
#      postgresql-$PG_VERSION postgresql-client-$PG_VERSION postgresql-contrib-$PG_VERSION && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/* && \
#    echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf && \
#    echo "listen_addresses='*'" >> /etc/postgresql/$PG_VERSION/main/postgresql.conf  && \
#    rm -rf /var/lib/postgresql/$PG_VERSION/main && \
#    update-rc.d -f postgresql disable

RUN apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-$PG_VERSION postgresql-client-$PG_VERSION postgresql-contrib-$PG_VERSION

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/$PG_VERSION/main/postgresql.conf

USER postgres
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER datacenter WITH SUPERUSER PASSWORD 'datacenter_password';" &&\
    createdb -O datacenter datacenter

#Java from web8 team
#RUN add-apt-repository -y ppa:webupd8team/java
#RUN apt-get update
#RUN echo oracle-java9-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
#RUN apt-get install oracle-java9-installer -y

#Setup Gradle
#RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip \
#&& mkdir /opt/gradle \
#&& unzip -d /opt/gradle gradle-${GRADLE_VERSION}-all.zip

#ADD postgresql.conf /etc/postgresql/$PG_VERSION/main/postgresql.conf
#ADD pg_hba.conf /etc/postgresql/$PG_VERSION/main/pg_hba.conf

VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

#Exposed ports
EXPOSE 5432
CMD ["/usr/lib/postgresql/9.5/bin/postgres", "-D", "/var/lib/postgresql/9.5/main", "-c", "config_file=/etc/postgresql/9.5/main/postgresql.conf"]
