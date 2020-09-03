#!/bin/bash

set -euo pipefail

# See http://guides.dataverse.org/en/latest/admin/metadatacustomization.html#updating-the-solr-schema
# for details on the following environment variables.
export TARGET=${TARGET:-"${SCHEMA_DIR}"}

# You can add any options you want to webhook. See https://github.com/adnanh/webhook
WEBHOOK_OPTS=${WEBHOOK_OPTS:-""}

cd ${SCHEMA_SCRIPT_DIR}
exec ./webhook `echo "$WEBHOOK_OPTS"`
