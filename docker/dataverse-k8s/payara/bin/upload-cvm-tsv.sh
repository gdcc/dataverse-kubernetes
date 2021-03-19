#!/bin/bash
################################################################################
# This script is used to configure a Dataverse installation from ...
# It is used solely for changing Database settings!
################################################################################
echo "------"
export CVM_SERVER_NAME=CESSDA
export CVM_SERVER_URL=https://cvm.dataverse.tk
export CVM_TSV_SOURCE=https://raw.githubusercontent.com/ekoi/speeltuin/master/resources/CMM_Custom_MetadataBlock.tsv
export GENERATED_DIR=generated
wget -O ${GENERATED_DIR}/cvmm.tsv ${CVM_TSV_SOURCE}
bash generate-cvm-setting.sh ${GENERATED_DIR}/cvmm.tsv ${GENERATED_DIR}/cvm-setting-from-tsv.json
bash upload-cvm-setting.sh http://localhost:8080  /Users/akmi/git/ekoi/speeltuin-v1/resources/keyword-setting.json

