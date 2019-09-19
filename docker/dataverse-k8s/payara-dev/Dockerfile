# Copyright 2019 Forschungszentrum Jülich GmbH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

############# BUILD DATAVERSE #############

FROM maven:3.5-jdk-8 as builder
# copy the project files
COPY dataverse/local_lib ./local_lib
COPY dataverse/pom.xml ./pom.xml
# build all dependencies for offline use
RUN mvn de.qaware.maven:go-offline-maven-plugin:resolve-dependencies
# copy your other files
COPY dataverse/src ./src
# build for release
RUN mvn -o package -DskipTests

############# BUILD IMAGE #############
# TODO: later the base can be the upstream image, which will speed up things (even more)
FROM payara/server-full:5.193
LABEL maintainer="FDM FZJ <forschungsdaten@fz-juelich.de>"

ENV DATA_DIR=/data\
    SECRETS_DIR=/secrets\
    PGDRIVER_PKG=https://jdbc.postgresql.org/download/postgresql-42.2.5.jar

# Create basic pathes
USER root
RUN mkdir -p ${DATA_DIR} ${SECRETS_DIR} && \
    chown -R payara: ${DATA_DIR} ${SECRETS_DIR}

# Install prerequisites
RUN apt-get -qq update && \
    apt-get -qqy install postgresql-client jq imagemagick curl

# Install PostgreSQL JDBC driver in AppServer
# TODO: remove this once upstream includes the Postgres Client lib in the WAR.
USER payara
RUN wget --no-verbose -O postgresql.jar ${PGDRIVER_PKG} && \
    mv postgresql.jar ${PAYARA_DIR}/glassfish/lib

# Create the Dataverse install directory and symlink WAR file
RUN mkdir ${HOME_DIR}/dvinstall && \
    ln -s ${HOME_DIR}/dvinstall/dataverse.war ${DEPLOY_DIR}/dataverse.war
# Copy files for the application
COPY --chown=payara:payara --from=builder /target/dataverse-*.war ${HOME_DIR}/dvinstall/dataverse.war
COPY --chown=payara:payara dataverse/scripts/api/data ${HOME_DIR}/dvinstall/data
COPY --chown=payara:payara dataverse/scripts/api/*.sh ${HOME_DIR}/dvinstall/
COPY --chown=payara:payara dataverse/scripts/database/reference_data.sql ${HOME_DIR}/dvinstall/
COPY --chown=payara:payara dataverse/conf/jhove/* ${HOME_DIR}/dvinstall/

# Copy across docker scripts
COPY --chown=payara:payara docker/dataverse-k8s/bin/* docker/dataverse-k8s/payara/bin/*.sh ${SCRIPT_DIR}/
RUN chmod +x ${SCRIPT_DIR}/*
