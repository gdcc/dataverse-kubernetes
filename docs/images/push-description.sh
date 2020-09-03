#!/bin/bash

# Fork of https://github.com/peter-evans/dockerhub-description/blob/master/entrypoint.sh

set -euo pipefail
IFS=$'\n\t'

# Set the path to the description
DESCRIPTION_FILE=${DESCRIPTION_FILE:-$(dirname "$0")"/${1:-"dataverse-k8s"}.md"}
if [ ! -s "${DESCRIPTION_FILE}" ]; then
  echo "Cannot find ${$DESCRIPTION_FILE}"
  exit 1
fi

# Acquire a token for the Docker Hub API
echo "Acquiring token"
LOGIN_PAYLOAD="{\"username\": \"${DOCKER_HUB_USR}\", \"password\": \"${DOCKER_HUB_PSW}\"}"
TOKEN=$(curl -sS -f -H "Content-Type: application/json" -X POST -d ${LOGIN_PAYLOAD} https://hub.docker.com/v2/users/login/ | jq -r .token)

# Send a PATCH request to update the description of the repository
echo "Sending PATCH request"
REPO_URL="https://hub.docker.com/v2/repositories/${DOCKER_IMAGE_NAME}/"
RESPONSE_CODE=$(curl -sS -f --write-out %{response_code} --output /dev/null -H "Authorization: JWT ${TOKEN}" -X PATCH --data-urlencode full_description@${DESCRIPTION_FILE} ${REPO_URL})
echo "Received response code: $RESPONSE_CODE"

if [ $RESPONSE_CODE -eq 200 ]; then
  exit 0
else
  exit 1
fi
