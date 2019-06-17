# Copyright 2019 Forschungszentrum Jülich GmbH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

FROM centos:7

LABEL maintainer="FDM FZJ <forschungsdaten@fz-juelich.de>"

ARG TINI_VERSION=v0.18.0
ARG VERSION=4.15
ARG DOMAIN=domain1

ENV HOME_DIR=/opt/dataverse\
    SCRIPT_DIR=/opt/dataverse/scripts\
    GLASSFISH_DIR=/opt/dataverse/appserver\
    DOMAIN_DIR=/opt/dataverse/appserver/glassfish/domains/${DOMAIN}\
    DATA_DIR=/data\
    SECRETS_DIR=/opt/dataverse/secrets\
    GLASSFISH_PKG=http://download.java.net/glassfish/4.1/release/glassfish-4.1.zip\
    GLASSFISH_SHA1=704a90899ec5e3b5007d310b13a6001575827293\
    WELD_PKG=http://central.maven.org/maven2/org/jboss/weld/weld-osgi-bundle/2.2.10.SP1/weld-osgi-bundle-2.2.10.SP1-glassfish4.jar\
    GRIZZLY_PKG=http://guides.dataverse.org/en/latest/_downloads/glassfish-grizzly-extra-all.jar\
    PGDRIVER_PKG=https://jdbc.postgresql.org/download/postgresql-42.2.5.jar\
    DATAVERSE_VERSION=${VERSION}\
    DATAVERSE_PKG=https://github.com/IQSS/dataverse/releases/download/v${VERSION}/dvinstall.zip
ENV PATH="${PATH}:${GLASSFISH_DIR}/bin"

# Install prerequisites
RUN yum install -y java-1.8.0-openjdk-headless epel-release unzip curl wget && \
    yum install -y postgresql jq ImageMagick

# Create and set the Glassfish user and working directory owned by the new user
RUN groupadd -g 1000 glassfish && \
    useradd -u 1000 -M -s /bin/bash -d ${HOME_DIR} glassfish -g glassfish && \
    echo glassfish:glassfish | chpasswd && \
    mkdir -p ${HOME_DIR} && \
    mkdir -p ${SCRIPT_DIR} && \
    mkdir -p ${SECRETS_DIR} && \
    mkdir -p ${DATA_DIR} && \
    chown -R glassfish: ${HOME_DIR} ${DATA_DIR}

# Install tini as minimized init system
RUN wget --no-verbose -O /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini && \
    wget --no-verbose -O /tini.asc https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc && \
    gpg --batch --keyserver "hkp://p80.pool.sks-keyservers.net:80" --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 && \
    gpg --batch --verify /tini.asc /tini && \
    chmod +x /tini

USER glassfish
WORKDIR ${HOME_DIR}

# Download, check and install Glassfish
RUN wget --no-verbose -O glassfish.zip ${GLASSFISH_PKG} && \
    echo "${GLASSFISH_SHA1} *glassfish.zip" | sha1sum -c - && \
    unzip -qq glassfish.zip -d ./ && \
    mv glassfish*/ appserver && \
    rm glassfish.zip

# Manually Patch Glassfish:
#   1) Replace insecure Weld Library
#   2) Replace OOM causing Grizzly lib
#   3) Replace outdated PKI store
# TODO: remove this once we can leave Glassfish 4.x
RUN wget --no-verbose -O weld-osgi-bundle.jar ${WELD_PKG} && \
    mv weld-osgi-bundle.jar ${GLASSFISH_DIR}/glassfish/modules && \
    wget --no-verbose -O glassfish-grizzly-extra-all.jar ${GRIZZLY_PKG} && \
    mv glassfish-grizzly-extra-all.jar ${GLASSFISH_DIR}/glassfish/modules && \
    cp /etc/pki/ca-trust/extracted/java/cacerts ${GLASSFISH_DIR}/glassfish/domains/domain1/config/cacerts.jks

# Tune basic settings
# 1) Set to use Server VM
# 2) Remove memory settings no longer needed since 8u191 (UseContainerSupport=true!)
RUN ${GLASSFISH_DIR}/bin/asadmin start-domain && \
    ${GLASSFISH_DIR}/bin/asadmin delete-jvm-options "-client" && \
    for MEMORY_JVM_OPTION in $(${GLASSFISH_DIR}/bin/asadmin list-jvm-options | grep "Xm[sx]"); do\
        ${GLASSFISH_DIR}/bin/asadmin delete-jvm-options $MEMORY_JVM_OPTION;\
    done && \
    ${GLASSFISH_DIR}/bin/asadmin create-jvm-options -- "-server" && \
    ${GLASSFISH_DIR}/bin/asadmin stop-domain && \
    mkdir -p ${DOMAIN_DIR}/autodeploy && \
    rm -rf \
        ${DOMAIN_DIR}/osgi-cache \
        ${DOMAIN_DIR}/logs

# Install PostgreSQL JDBC driver in AppServer
RUN wget --no-verbose -O postgresql.jar ${PGDRIVER_PKG} && \
    mv postgresql.jar ${GLASSFISH_DIR}/glassfish/lib

# Retrieve the Dataverse install package, extract and remove ZIP
RUN wget --no-verbose -O dvinstall.zip ${DATAVERSE_PKG} && \
    unzip -qq dvinstall.zip -d ./ && \
    rm dvinstall.zip

# Copy across docker scripts
COPY --chown=glassfish:glassfish bin/*.sh bin/default.config ${SCRIPT_DIR}/
RUN mkdir -p ${SCRIPT_DIR}/init.d && \
    chmod +x ${SCRIPT_DIR}/*

ENTRYPOINT ["/tini", "--"]
CMD ["scripts/entrypoint.sh"]
