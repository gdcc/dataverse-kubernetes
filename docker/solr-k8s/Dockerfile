# Copyright 2019 Forschungszentrum Jülich GmbH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

FROM solr:7.3.1

LABEL maintainer="FDM FZJ <forschungsdaten@fz-juelich.de>"

ARG VERSION=4.17
ARG COLLECTION=collection1
ENV SOLR_OPTS="-Dsolr.jetty.request.header.size=102400"\
    COLLECTION_DIR=/opt/solr/server/solr/${COLLECTION}\
    SCHEMA_DIR=/schema\
    DATAVERSE_PKG=https://github.com/IQSS/dataverse/releases/download/v${VERSION}/dvinstall.zip

# Create schema store
USER root
RUN mkdir -p ${SCHEMA_DIR} && \
    chown -R ${SOLR_USER}: ${SCHEMA_DIR}

USER ${SOLR_USER}
WORKDIR /tmp

# Dataverse uses a **hardcoded** core name "collection1", so we need to use it.
# 1) Create core directory
# 2) Copy _default configset
# 3) Create core.properties
RUN mkdir -p ${COLLECTION_DIR} && \
    cp -a ${COLLECTION_DIR}/../configsets/_default/conf ${COLLECTION_DIR} && \
    echo "name=${COLLECTION}" > ${COLLECTION_DIR}/core.properties

# Download dvinstall.zip, extract, copy schema and config, remove install files
RUN wget --no-verbose -O dvinstall.zip ${DATAVERSE_PKG} && \
    unzip -qq dvinstall.zip -d ./ && \
    mkdir -p ${COLLECTION_DIR}/conf && \
    mv dvinstall/solrconfig.xml ${COLLECTION_DIR}/conf/solrconfig.xml && \
    mv dvinstall/schema*.xml ${COLLECTION_DIR}/conf/ && \
    rm -rf dvinstall dvinstall.zip

# Edit schema.xml to include /schema located files, but fallback to default
RUN sed -i -e "s#^.*:include href=\"schema_dv_mdb_fields.*\$#    <xi:include href=\"file:${SCHEMA_DIR}/schema_dv_mdb_fields.xml\" xmlns:xi=\"http://www.w3.org/2001/XInclude\">\n      <xi:fallback><xi:include href=\"schema_dv_mdb_fields.xml\"/></xi:fallback>\n    </xi:include>#" ${COLLECTION_DIR}/conf/schema.xml && \
    sed -i -e "s#^.*:include href=\"schema_dv_mdb_copies.*\$#    <xi:include href=\"file:${SCHEMA_DIR}/schema_dv_mdb_copies.xml\" xmlns:xi=\"http://www.w3.org/2001/XInclude\">\n      <xi:fallback><xi:include href=\"schema_dv_mdb_copies.xml\"/></xi:fallback>\n    </xi:include>#" ${COLLECTION_DIR}/conf/schema.xml
