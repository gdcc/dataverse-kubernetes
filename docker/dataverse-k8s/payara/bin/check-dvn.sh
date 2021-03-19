#!/bin/bash
echo "Checking the Dataverse running status" >> /tmp/status.log
#${PAYARA_DIR}/bin/asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} deploy /opt/payara/dvinstall/dataverse.war
until curl -sS -f "http://dataverse:8080/robots.txt" -m 2 2>&1 > /dev/null;
    do echo ">>>>>>>> Waiting for Dataverse...." >> /tmp/status.log; echo "---- Dataverse is not ready...." >> /tmp/status.log; sleep 5; done;
    sleep 5;
    echo "Dataverse is running...!" >> /tmp/status.log;
echo "---Enjoy Dataversing--" >> /tmp/status.log
if [ "${CVM_CONFIG}" ]; then
    curl -H "Content-Type: application/json" -X PUT --data-binary @${HOME_DIR}/dvinstall/data/metadatablocks/keys_config.json http://localhost:8080/api/admin/settings/:CVMConf
    psql -U dvnuser dvndb -h postgres -f ${HOME_DIR}/dvinstall/data/metadatablocks/cvm.sql
fi
