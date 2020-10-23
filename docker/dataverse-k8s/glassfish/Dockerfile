# Copyright 2019 Forschungszentrum Jülich GmbH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

FROM centos:7

LABEL maintainer="FDM FZJ <forschungsdaten@fz-juelich.de>"

ARG TINI_VERSION=v0.19.0
ARG JMX_EXPORTER_VERSION=0.12.0
ARG VERSION=4.20
ARG DOMAIN=domain1

ENV HOME_DIR=/opt/dataverse\
    SCRIPT_DIR=/opt/dataverse/scripts\
    GLASSFISH_DIR=/opt/dataverse/appserver\
    DOMAIN_DIR=/opt/dataverse/appserver/glassfish/domains/${DOMAIN}\
    DATA_DIR=/data\
    DOCROOT_DIR=/docroot\
    METADATA_DIR=/metadata\
    SECRETS_DIR=/secrets\
    DUMPS_DIR=/dumps\
    GLASSFISH_PKG=http://download.java.net/glassfish/4.1/release/glassfish-4.1.zip\
    GLASSFISH_SHA1=704a90899ec5e3b5007d310b13a6001575827293\
    WELD_PKG=https://repo1.maven.org/maven2/org/jboss/weld/weld-osgi-bundle/2.2.10.SP1/weld-osgi-bundle-2.2.10.SP1-glassfish4.jar\
    GRIZZLY_PKG=http://guides.dataverse.org/en/${VERSION}/_downloads/glassfish-grizzly-extra-all.jar\
    PGDRIVER_PKG=https://jdbc.postgresql.org/download/postgresql-42.2.12.jar\
    DATAVERSE_VERSION=${VERSION}\
    DATAVERSE_PKG=https://github.com/IQSS/dataverse/releases/download/v${VERSION}/dvinstall.zip\
    JMX_EXPORTER_PKG=https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar\
    MEM_MAX_RAM_PERCENTAGE=70.0\
    MEM_XSS=512k
ENV PATH="${PATH}:${GLASSFISH_DIR}/bin"

# Install prerequisites
RUN yum install -y java-1.8.0-openjdk-headless epel-release unzip curl wget && \
    yum install -y postgresql jq ImageMagick && \
    yum clean all

# Create and set the Glassfish user and working directory owned by the new user
RUN groupadd -g 1000 glassfish && \
    useradd -u 1000 -M -s /bin/bash -d ${HOME_DIR} glassfish -g glassfish && \
    echo glassfish:glassfish | chpasswd && \
    mkdir -p ${HOME_DIR} ${SCRIPT_DIR} ${SECRETS_DIR} && \
    mkdir -p ${DATA_DIR} ${METADATA_DIR} ${DOCROOT_DIR} ${DUMPS_DIR} && \
    chown -R glassfish: ${HOME_DIR} ${DATA_DIR} ${METADATA_DIR} ${DOCROOT_DIR} ${DUMPS_DIR}

# Install tini as minimized init system
RUN wget --no-verbose -O tini-amd64 https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 && \
    echo '93dcc18adc78c65a028a84799ecf8ad40c936fdfc5f2a57b1acda5a8117fa82c tini-amd64' | sha256sum -c - && \
    mv tini-amd64 /tini && chmod +x /tini

# Install esh template engine from Github
RUN wget --no-verbose -O esh https://raw.githubusercontent.com/jirutka/esh/v0.3.0/esh && \
    echo 'fe030e23fc1383780d08128eecf322257cec743b esh' | sha1sum -c - && \
    chmod +x esh && mv esh /usr/local/bin

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

# Make docroot of Glassfish reside in higher level directory for easier targeting
# Due to IQSS/dataverse-kubernetes#177: create the generated pathes so they are
# writeable by us. TBR with #178.
RUN rm -rf ${DOMAIN_DIR}/docroot && \
    ln -s ${DOCROOT_DIR} ${DOMAIN_DIR}/docroot && \
    mkdir -p ${DOMAIN_DIR}/generated/jsp/dataverse

# Tune basic settings
# 1) Set to use Server VM
# 2) Remove memory settings no longer needed since 8u191 (UseContainerSupport=true!)
RUN ${GLASSFISH_DIR}/bin/asadmin start-domain && \
    ${GLASSFISH_DIR}/bin/asadmin delete-jvm-options "-client" && \
    for MEMORY_JVM_OPTION in $(${GLASSFISH_DIR}/bin/asadmin list-jvm-options | grep "Xm[sx]"); do\
        ${GLASSFISH_DIR}/bin/asadmin delete-jvm-options $MEMORY_JVM_OPTION;\
    done && \
    ${GLASSFISH_DIR}/bin/asadmin create-jvm-options -- "-XX\:+HeapDumpOnOutOfMemoryError" && \
    ${GLASSFISH_DIR}/bin/asadmin create-jvm-options -- "-XX\:HeapDumpPath=${DUMPS_DIR}" && \
    ${GLASSFISH_DIR}/bin/asadmin create-jvm-options -- "-XX\:+UseG1GC" && \
    ${GLASSFISH_DIR}/bin/asadmin create-jvm-options -- "-XX\:+UseStringDeduplication" && \
    ${GLASSFISH_DIR}/bin/asadmin create-jvm-options -- "-XX\:MaxGCPauseMillis=500" && \
    ${GLASSFISH_DIR}/bin/asadmin create-jvm-options -- "-XX\:MetaspaceSize=256m" && \
    ${GLASSFISH_DIR}/bin/asadmin create-jvm-options -- "-XX\:MaxMetaspaceSize=2g" && \
    ${GLASSFISH_DIR}/bin/asadmin create-jvm-options -- "-XX\:+IgnoreUnrecognizedVMOptions" && \
    ${GLASSFISH_DIR}/bin/asadmin create-jvm-options -- "-server" && \
    ${GLASSFISH_DIR}/bin/asadmin stop-domain && \
    mkdir -p ${DOMAIN_DIR}/autodeploy && \
    rm -rf \
        ${DOMAIN_DIR}/osgi-cache \
        ${DOMAIN_DIR}/logs

# Install PostgreSQL JDBC driver in AppServer
RUN wget --no-verbose -O postgresql.jar ${PGDRIVER_PKG} && \
    mv postgresql.jar ${GLASSFISH_DIR}/glassfish/lib

# Get Prometheus JMX Exporter Java Agent (see https://github.com/prometheus/jmx_exporter)
RUN wget --no-verbose -O ${HOME}/jmx_exporter_agent.jar ${JMX_EXPORTER_PKG} && \
    echo -e "---\n{}" > ${HOME}/jmx_exporter_config.yaml

# Retrieve the Dataverse install package, extract and remove ZIP,
#   remove Harvard custom metadatablocks
RUN wget --no-verbose -O dvinstall.zip ${DATAVERSE_PKG} && \
    unzip -qq dvinstall.zip -d ./ && \
    rm dvinstall.zip && \
    find . -iname "custom*.tsv" -delete

# Copy across docker scripts
COPY --chown=glassfish:glassfish docker/dataverse-k8s/bin/* docker/dataverse-k8s/glassfish/bin/* ${SCRIPT_DIR}/
RUN mkdir -p ${SCRIPT_DIR}/init.d && \
    chmod +x ${SCRIPT_DIR}/*

ENTRYPOINT ["/tini", "--"]
CMD ["scripts/entrypoint.sh"]
