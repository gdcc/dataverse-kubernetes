#!/bin/bash
################################################################################
# This script is used to configure a Dataverse installation from ...
# It is used solely for changing Database settings!
################################################################################
echo "--" > /tmp/status.log;
until curl -sS -f "http://localhost:8080/robots.txt" -m 2 2>&1 > /dev/null;
    do echo ">>>>>>>> Waiting for Dataverse...." >> /tmp/status.log; echo "---- Dataverse is not ready...." >> /tmp/status.log; sleep 20; done;
    echo "Dataverse is running...But it has no data. Setup initial data.">> /tmp/status.log;
 echo "---Updating reference_data.sql--" >> /tmp/status.log;
 sleep 20;

if [ -s "${HOME_DIR}/dvinstall/reference_data.sql" ]; then
  psql -U ${POSTGRES_USER} -h ${POSTGRES_SERVER} -d ${POSTGRES_DATABASE} -f ${HOME_DIR}/dvinstall/reference_data.sql
fi

DV_SU_PASSWORD="admin"


command -v jq >/dev/null 2>&1 || { echo >&2 '`jq` ("sed for JSON") is required, but not installed. Download the binary for your platform from http://stedolan.github.io/jq/ and make sure it is in your $PATH (/usr/bin/jq is fine) and executable with `sudo chmod +x /usr/bin/jq`. On Mac, you can install it with `brew install jq` if you use homebrew: http://brew.sh . Aborting.'; exit 1; }

echo "deleting all data from Solr"  >> /tmp/status.log;
curl http://solr:8983/solr/collection1/update/json?commit=true -H "Content-type: application/json" -X POST -d "{\"delete\": { \"query\":\"*:*\"}}" >> /tmp/status.log;

SERVER=http://localhost:8080/api

# Everything + the kitchen sink, in a single script
# - Setup the metadata blocks and controlled vocabulary
# - Setup the builtin roles
# - Setup the authentication providers
# - setup the settings (local sign-in)
# - Create admin user and root dataverse
# - (optional) Setup optional users and dataverses


echo "Setup the metadata blocks" >> /tmp/status.log
bash ./setup-datasetfields.sh

echo "Setup the builtin roles" >> /tmp/status.log
bash ./setup-builtin-roles.sh

echo "Setup the authentication providers" >> /tmp/status.log
bash ./setup-identity-providers.sh



echo "Setting up the settings" >> /tmp/status.log
echo  "- Allow internal signup" >> /tmp/status.log
curl -X PUT -d yes "$SERVER/admin/settings/:AllowSignUp"
curl -X PUT -d /dataverseuser.xhtml?editMode=CREATE "$SERVER/admin/settings/:SignUpUrl"

curl -X PUT -d doi "$SERVER/admin/settings/:Protocol"
curl -X PUT -d 10.5072 "$SERVER/admin/settings/:Authority"
curl -X PUT -d "FK2/" "$SERVER/admin/settings/:Shoulder"
curl -X PUT -d FAKE "$SERVER/admin/settings/:DoiProvider"
curl -X PUT -d burrito $SERVER/admin/settings/BuiltinUsers.KEY
curl -X PUT -d localhost-only $SERVER/admin/settings/:BlockedApiPolicy
curl -X PUT -d 'native/http' $SERVER/admin/settings/:UploadMethods
curl -X PUT -d solr:8983 "$SERVER/admin/settings/:SolrHostColonPort"
echo



echo "Setting up the admin user (and as superuser)" >> /tmp/status.log
adminResp=$(curl -s -H "Content-type:application/json" -X POST -d @data/user-admin.json "$SERVER/builtin-users?password=$DV_SU_PASSWORD&key=burrito")
echo $adminResp
curl -X POST "$SERVER/admin/superuser/dataverseAdmin"
echo

echo "Setting up the root dataverse" >> /tmp/status.log
adminKey=$(echo $adminResp | jq .data.apiToken | tr -d \")
curl -s -H "Content-type:application/json" -X POST -d @data/dv-root.json "$SERVER/dataverses/?key=$adminKey"
echo
echo "Set the metadata block for Root" >> /tmp/status.log
curl -s -X POST -H "Content-type:application/json" -d "[\"citation\"]" $SERVER/dataverses/:root/metadatablocks/?key=$adminKey
echo
echo "Set the default facets for Root" >> /tmp/status.log
curl -s -X POST -H "Content-type:application/json" -d "[\"authorName\",\"subject\",\"keywordValue\",\"dateOfDeposit\"]" $SERVER/dataverses/:root/facets/?key=$adminKey
echo

if [ "${CVM_SERVER_NAME}" ]; then
    echo "Uploading ${CVM_SERVER_NAME} metadatablock" >> /tmp/status.log
    curl http://localhost:8080/api/admin/datasetfield/load -X POST --data-binary @data/metadatablocks/cvmm.tsv -H "Content-type: text/tab-separated-values"

    #curl -H "Content-Type: application/json" -X PUT --data-binary @data/cvm-setting.json "$SERVER/admin/settings/:CVMConf"
    echo "Uploading cvm-setting.json" >> /tmp/status.log

fi

if [ "${CVM_CONFIG}" ]; then
    echo "Dowload keywords configuration file from ${CVM_TSV_SOURCE}" >> /tmp/status.log;
    wget -O ${HOME_DIR}/dvinstall/data/metadatablocks/keys_config.json ${CVM_CONFIG}
    wget -O ${HOME_DIR}/dvinstall/data/metadatablocks/cvm.sql ${CVM_SQL}
    curl -H "Content-Type: application/json" -X PUT --data-binary @${HOME_DIR}/dvinstall/data/metadatablocks/keys_config.json http://localhost:8080/api/admin/settings/:CVMConf
    psql -U dvnuser dvndb -h postgres -f ${HOME_DIR}/dvinstall/data/metadatablocks/cvm.sql
fi

# OPTIONAL USERS AND DATAVERSES
#./setup-optional.sh
echo
echo "Setup done. Enjoy Dataversing...." >> /tmp/status.log
