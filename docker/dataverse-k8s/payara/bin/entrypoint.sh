#!/bin/bash

for f in ${SCRIPT_DIR}/init_* ${SCRIPT_DIR}/init.d/*; do
      case "$f" in
        *.sh)  echo "[Entrypoint] running $f"; . "$f" ;;
        *)     echo "[Entrypoint] ignoring $f" ;;
      esac
      echo
done

exec ${SCRIPT_DIR}/startInForeground.sh $PAYARA_ARGS
if [ "${GIT_CVM_TEMPLATES}" ]; then
    #echo "Clone dataverse templates from ${GIT_CVM_TEMPLATES}" >> /tmp/status.log;
    #git clone ${GIT_CVM_TEMPLATES} /tmp/cvm-templates;
    #cd /tmp/cvm-templates; git fetch; git pull origin master;
    cp -R /tmp/cvm-templates/templates/dataverse/* /opt/payara/appserver/glassfish/domains/production/applications/dataverse/
fi

