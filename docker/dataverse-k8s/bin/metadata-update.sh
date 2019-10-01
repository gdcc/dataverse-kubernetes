#!/bin/bash
################################################################################
# This script is used to update metadata blocks from release and custom files.
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

# Find all TSV files
TSVS=`find "${METADATA_DIR}" "${HOME_DIR}" -maxdepth 5 -iname '*.tsv'`

# Check for builtin blocks to be present
BUILTIN=("astrophysics.tsv" "biomedical.tsv" "citation.tsv" "geospatial.tsv" "journals.tsv" "social_science.tsv")
miss=1
fail=1
for mdb in "${BUILTIN[@]}"; do
  grep "${mdb}" <<< "${TSVS}" > /dev/null 2>&1 || miss=0
  if [ $miss -eq 0 ]; then
    echo "ERROR: could not find builtin (release) metadata block file ${mdb} within ${METADATA_DIR} or ${HOME_DIR}"
    fail=0
    miss=1
  fi
done

# Abort if any builtin metadata file has not been find- or readable
if [ $fail -eq 0 ]; then
  echo "Aborting."
  exit 125
fi

# Load metadata blocks
echo "${TSVS}" | xargs -n1 -I "%mdb%" sh -c "echo -n \"Loading %mdb%: \"; curl -sS -f -H \"Content-type: text/tab-separated-values\" -X POST --data-binary \"@%mdb%\" \"${DATAVERSE_URL}/api/admin/datasetfield/load?unblock-key=${API_KEY}\" 2>&1 | jq -M '.status'"
