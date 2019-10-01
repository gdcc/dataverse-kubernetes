#!/bin/bash
################################################################################
# This script is used to configure a Dataverse installation from a ConfigMap.
# It is used solely for changing Database settings!
################################################################################

# Fail on any error
set -euo pipefail
DATAVERSE_SERVICE_HOST=${DATAVERSE_SERVICE_HOST:-"dataverse"}
DATAVERSE_SERVICE_PORT=${DATAVERSE_SERVICE_PORT:-"8080"}
DATAVERSE_URL=${DATAVERSE_URL:-"http://${DATAVERSE_SERVICE_HOST}:${DATAVERSE_SERVICE_PORT}"}

# Check API key secret is available
if [ ! -s "${SECRETS_DIR}/api/key" ]; then
  echo "No API key present. Failing."
  exit 126
fi
API_KEY=`cat ${SECRETS_DIR}/api/key`

# Set Database options based on environment variables db_XXX from ConfigMap
echo "Setting Database options for Dataverse:"
env | grep -Ee "^(db)_" | sort -fd
env -0 | grep -z -Ee "^(db)_" | while IFS='=' read -r -d '' k v; do
    KEY=`echo "${k}" | sed -e 's/^db_/:/'`
    echo "Handling ${KEY}=${v}."
    if [[ -z "${v}" ]]; then
      # empty var => delete the setting
      curl -X DELETE "${DATAVERSE_URL}/api/admin/settings/${KEY}?unblock-key=${API_KEY}"
    else
      # set the setting
      curl -X PUT -d "${v}" "${DATAVERSE_URL}/api/admin/settings/${KEY}?unblock-key=${API_KEY}"
    fi
done

# TODO: think about how to POST the configs for OAuth, etc
