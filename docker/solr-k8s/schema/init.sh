#!/bin/bash

# Fail on any error (but not errexit, as we want to be gracefull!)
set -uo pipefail

DATAVERSE_SERVICE_HOST=${DATAVERSE_SERVICE_HOST:-"dataverse"}
DATAVERSE_SERVICE_PORT=${DATAVERSE_SERVICE_PORT:-"8080"}
DATAVERSE_URL=${DATAVERSE_URL:-"http://${DATAVERSE_SERVICE_HOST}:${DATAVERSE_SERVICE_PORT}"}
SOLR_URL="http://localhost:8983"
TARGET="/schema"

# Check API key secret is available
if [ ! -s "/scripts/schema/api/key" ]; then
  echo "No API key present. Failing."
  exit 126
fi
UNBLOCK_KEY=`cat /scripts/schema/api/key`

${SCHEMA_SCRIPT_DIR}/update.sh \
  -t "$TARGET" \
  -s "$SOLR_URL" \
  -u "$UNBLOCK_KEY" \
  -d "$DATAVERSE_URL" \
  || echo "Failing gracefully to allow startup."
