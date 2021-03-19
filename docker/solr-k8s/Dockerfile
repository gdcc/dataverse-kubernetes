# Copyright 2019 Forschungszentrum Jülich GmbH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

FROM solr:7.7

LABEL maintainer="FDM FZJ <forschungsdaten@fz-juelich.de>"

ARG WEBHOOK_VERSION=2.6.11
ARG TINI_VERSION=v0.18.0
ARG VERSION=4.20
ARG COLLECTION=collection1
ENV SOLR_OPTS="-Dsolr.jetty.request.header.size=102400"\
    COLLECTION_DIR=/opt/solr/server/solr/${COLLECTION}\
    SCHEMA_DIR=/schema\
    SCRIPT_DIR=/scripts\
    DATAVERSE_PKG=https://github.com/IQSS/dataverse/releases/download/v${VERSION}/dvinstall.zip
ENV SCHEMA_SCRIPT_DIR=${SCRIPT_DIR}/schema

# Create schema store and scripts folder if not present, change permissions
USER root
RUN mkdir -p ${SCHEMA_DIR} ${SCRIPT_DIR} ${SCHEMA_SCRIPT_DIR} && \
    chown -R ${SOLR_USER}: ${SCHEMA_DIR} ${SCRIPT_DIR} ${SCHEMA_SCRIPT_DIR}

# Install tini as minimized init system
RUN wget --no-verbose -O /tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini && \
    chmod +x /tini

USER ${SOLR_USER}

# Dataverse uses a **hardcoded** core name "collection1", so we need to use it.
# 1) Create core directory
# 2) Copy _default configset
# 3) Create core.properties
RUN mkdir -p ${COLLECTION_DIR} && \
    cp -a ${COLLECTION_DIR}/../configsets/_default/conf ${COLLECTION_DIR} && \
    echo "name=${COLLECTION}" > ${COLLECTION_DIR}/core.properties

# Download dvinstall.zip, extract, copy schema and config, remove install files
# Copy script for schema creation.
RUN wget --no-verbose -O dvinstall.zip ${DATAVERSE_PKG} && \
    unzip -qq dvinstall.zip -d ./ && \
    mkdir -p ${COLLECTION_DIR}/conf && \
    mv dvinstall/solrconfig.xml ${COLLECTION_DIR}/conf/solrconfig.xml && \
    mv dvinstall/schema*.xml ${COLLECTION_DIR}/conf/ && \
    mv dvinstall/updateSchemaMDB.sh ${SCHEMA_SCRIPT_DIR}/ && \
    rm -rf dvinstall dvinstall.zip

# Edit schema.xml to include /schema located files, but fallback to default
RUN ln -s /schema ${COLLECTION_DIR}/conf/schema && \
    sed -i -e "s#^.*:include href=\"schema_dv_mdb_fields.*\$#    <xi:include href=\"schema/schema_dv_mdb_fields.xml\" xmlns:xi=\"http://www.w3.org/2001/XInclude\">\n      <xi:fallback><xi:include href=\"schema_dv_mdb_fields.xml\"/></xi:fallback>\n    </xi:include>#" ${COLLECTION_DIR}/conf/schema.xml && \
    sed -i -e "s#^.*:include href=\"schema_dv_mdb_copies.*\$#    <xi:include href=\"schema/schema_dv_mdb_copies.xml\" xmlns:xi=\"http://www.w3.org/2001/XInclude\">\n      <xi:fallback><xi:include href=\"schema_dv_mdb_copies.xml\"/></xi:fallback>\n    </xi:include>#" ${COLLECTION_DIR}/conf/schema.xml

### SIDECAR BELONGINGS

# Prepare everything for schema update sidecar
RUN wget --no-verbose -O webhook.tar.gz https://github.com/adnanh/webhook/releases/download/${WEBHOOK_VERSION}/webhook-linux-amd64.tar.gz && \
    tar -xzf webhook.tar.gz --strip-components=1 -C ${SCHEMA_SCRIPT_DIR} && \
    chmod +x ${SCHEMA_SCRIPT_DIR}/webhook && \
    rm webhook.tar.gz
COPY --chown=solr:solr schema/ ${SCHEMA_SCRIPT_DIR}
RUN chmod +x ${SCHEMA_SCRIPT_DIR}/*.sh
