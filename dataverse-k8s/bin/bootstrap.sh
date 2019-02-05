#!/bin/bash
################################################################################
# This script is used to bootstrap a Dataverse installation.
#
# It runs all necessary database foo that cannot be done from EclipseLink.
# It initializes the most basic settings and
# creates root dataverse and admin account.
################################################################################

# Fail on any error
set -e
# Include some sane defaults
. ${SCRIPT_DIR}/default.config
DATAVERSE_K8S_HOST=${DATAVERSE_K8S_HOST:-${DATAVERSE_SERVICE_HOST}}
SOLR_K8S_HOST=${SOLR_K8S_HOST:-${SOLR_SERVICE_HOST}}

# Drop the Postgres credentials into .pgpass
echo "${POSTGRES_SERVER}:*:*:${POSTGRES_USER}:`cat ${SECRETS_DIR}/db/password`" > ${HOME_DIR}/.pgpass
cat ${HOME_DIR}/.pgpass
chmod 0600 ${HOME_DIR}/.pgpass

# 1.) Load SQL data
psql -h ${POSTGRES_SERVER} -U ${POSTGRES_USER} ${POSTGRES_DATABASE} < ${HOME_DIR}/dvinstall/reference_data.sql

# 2a.) Patch load scripts with k8s based URL
cd ${HOME_DIR}/dvinstall
sed -i -e "s#localhost:8080#${DATAVERSE_K8S_HOST}:8080#" setup-*.sh

# 2b) Patch user script with admin email
# T. B. D.

# 3.) Use scripts to bootstrap the instance.
./setup-all.sh --insecure

# 4.) Configure Solr location
curl -X PUT -d "${SOLR_K8S_HOST}:8983" http://${DATAVERSE_K8S_HOST}:8080/api/admin/settings/:SolrHostColonPort

# 5.) Block access to the API endpoints, but allow for request with key from secret
# T. B. D.
