#!/bin/bash

# Fail on any error (but not errexit, as we want to be gracefull!)
set -uo pipefail

DATAVERSE_SERVICE_HOST=${DATAVERSE_SERVICE_HOST:-"dataverse"}
DATAVERSE_SERVICE_PORT_HTTP=${DATAVERSE_SERVICE_PORT_HTTP:-"8080"}
DATAVERSE_URL=${DATAVERSE_URL:-"http://${DATAVERSE_SERVICE_HOST}:${DATAVERSE_SERVICE_PORT_HTTP}"}
SOLR_URL="http://localhost:8983"
TARGET="/schema"

# Check API key secret is available
if [ ! -s "/scripts/schema/api/key" ]; then
  echo "No API key present. Failing."
  exit 126
fi
UNBLOCK_KEY=`cat /scripts/schema/api/key`

${SCHEMA_SCRIPT_DIR}/updateSchemaMDB.sh \
  -t "$TARGET" \
  -s "$SOLR_URL" \
  -u "$UNBLOCK_KEY" \
  -d "$DATAVERSE_URL" \
  || echo "Failing gracefully to allow startup."
