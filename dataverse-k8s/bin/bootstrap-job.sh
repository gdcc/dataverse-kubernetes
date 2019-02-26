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

# Check postgres and API key secrets are available
if [ ! -s "${SECRETS_DIR}/db/password" ]; then
  echo "No database password present. Failing."
  exit 126
fi
if [ ! -s "${SECRETS_DIR}/api/key" ]; then
  echo "No API key present. Failing."
  exit 126
fi

# Drop the Postgres credentials into .pgpass
echo "${POSTGRES_SERVER}:*:*:${POSTGRES_USER}:`cat ${SECRETS_DIR}/db/password`" > ${HOME_DIR}/.pgpass
chmod 0600 ${HOME_DIR}/.pgpass

# 1.) Load SQL data
psql -h ${POSTGRES_SERVER} -U ${POSTGRES_USER} ${POSTGRES_DATABASE} < ${HOME_DIR}/dvinstall/reference_data.sql

# 2) Initialize common data structures to make Dataverse usable
cd ${HOME_DIR}/dvinstall
# 2a) Patch load scripts with k8s based URL
sed -i -e "s#localhost:8080#${DATAVERSE_K8S_HOST}:8080#" setup-*.sh
# 2b) Patch user and root dataverse JSON with contact email
sed -i -e "s#root@mailinator.com#${CONTACT_MAIL}#" data/dv-root.json
sed -i -e "s#dataverse@mailinator.com#${CONTACT_MAIL}#" data/user-admin.json
# 2c) Use script(s) to bootstrap the instance.
./setup-all.sh --insecure

# 4.) Configure Solr location
curl -X PUT -d "${SOLR_K8S_HOST}:8983" "http://${DATAVERSE_K8S_HOST}:8080/api/admin/settings/:SolrHostColonPort"

# 5.) Configure system email (otherwise no email will be send)
curl -X PUT -d "${ADMIN_MAIL}" "http://${DATAVERSE_K8S_HOST}:8080/api/admin/settings/:SystemEmail"

# 6.) Block access to the API endpoints, but allow for request with key from secret
curl -X DELETE "http://${DATAVERSE_K8S_HOST}:8080/api/admin/settings/BuiltinUsers.KEY"
curl -X PUT -d "`cat ${SECRETS_DIR}/api/key`" "http://${DATAVERSE_K8S_HOST}:8080/api/admin/settings/:BlockedApiKey"
curl -X PUT -d unblock-key "http://${DATAVERSE_K8S_HOST}:8080/api/admin/settings/:BlockedApiPolicy"
curl -X PUT -d admin,test "http://${DATAVERSE_K8S_HOST}:8080/api/admin/settings/:BlockedApiEndpoints"
