# Copyright 2019 Forschungszentrum Jülich GmbH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

############# BUILD DATAVERSE #############

FROM iqss/dataverse-k8s:build-cache as builder
# copy the project files
COPY dataverse/local_lib ./local_lib
COPY dataverse/pom.xml ./pom.xml
# copy your source files
COPY dataverse/src ./src
# build WAR with maven
RUN mvn package -DskipTests

############# BUILD IMAGE #############
FROM iqss/dataverse-k8s:payara
LABEL maintainer="FDM FZJ <forschungsdaten@fz-juelich.de>"

ENV JREBEL_LIB=/opt/dataverse/jrebel/lib/libjrebel64.so
RUN wget --no-verbose -O "${HOME_DIR}/jrebel.zip" http://dl.zeroturnaround.com/jrebel-stable-nosetup.zip && \
    unzip -q "${HOME_DIR}/jrebel.zip" -d "${HOME_DIR}"

# Copy files for the application
COPY --chown=payara:payara --from=builder /target/dataverse-*.war ${HOME_DIR}/dvinstall/dataverse.war
COPY --chown=payara:payara dataverse/scripts/api/data ${HOME_DIR}/dvinstall/data
COPY --chown=payara:payara dataverse/scripts/api/*.sh ${HOME_DIR}/dvinstall/
COPY --chown=payara:payara dataverse/scripts/database/reference_data.sql ${HOME_DIR}/dvinstall/
COPY --chown=payara:payara dataverse/conf/jhove/* ${HOME_DIR}/dvinstall/

# Copy across docker scripts
COPY --chown=payara:payara docker/dataverse-k8s/bin/* docker/dataverse-k8s/payara/bin/* docker/dataverse-k8s/payara-dev/bin/* ${SCRIPT_DIR}/
RUN mkdir -p ${SCRIPT_DIR}/init.d && \
    chmod +x ${SCRIPT_DIR}/*
