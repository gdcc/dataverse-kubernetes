#!/bin/bash
################################################################################
# This script is used to configure a Dataverse installation from a ConfigMap.
# It is used solely for changing Database settings!
################################################################################

# Fail on any error
set -e
DATAVERSE_K8S_HOST=${DATAVERSE_K8S_HOST:-${DATAVERSE_SERVICE_HOST}}

# Check API key secret is available
if [ ! -s "${SECRETS_DIR}/api/key" ]; then
  echo "No API key present. Failing."
  exit 126
fi
API_KEY=`cat ${SECRETS_DIR}/api/key`

# 3. Domain based configuration options
# Set Dataverse environment variables
echo "Setting system properties for Dataverse configuration options:"
env | grep -Ee "^(db)_" | sort -fd
env -0 | grep -z -Ee "^(db)_" | while IFS='=' read -r -d '' k v; do
    KEY=`echo "${k}" | sed -e 's/^db_/:/'`
    echo "Handling ${KEY}=${v}."
    if [[ -z "${v}" ]]; then
      # empty var => delete the setting
      curl -X DELETE "http://${DATAVERSE_K8S_HOST}:8080/api/admin/settings/${KEY}?unblock-key=${API_KEY}"
    else
      # set the setting
      curl -X PUT -d "${v}" "http://${DATAVERSE_K8S_HOST}:8080/api/admin/settings/${KEY}?unblock-key=${API_KEY}"
    fi
done
