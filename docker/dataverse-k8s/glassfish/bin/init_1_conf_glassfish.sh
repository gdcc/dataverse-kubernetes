#!/bin/bash
################################################################################
# Configure Glassfish
#
# BEWARE: As this is done for Kubernetes, we will ALWAYS start with a fresh container!
#         When moving to Glassfish/Payara 5+ the option commands are idempotent.
#         The resources are to be created by the application on deployment,
#         once Dataverse has proper refactoring, etc.
#         See upstream issue IQSS/dataverse#5292
################################################################################

# Fail on any error
set -e
# Include some sane defaults
. ${SCRIPT_DIR}/default.config

# 0. Start the domain
asadmin start-domain

# 1. Password aliases from secrets
for alias in rserve doi db
do
  if [ -f ${SECRETS_DIR}/$alias/password ]; then
    cat ${SECRETS_DIR}/$alias/password | sed -e "s#^#AS_ADMIN_ALIASPASSWORD=#" > /tmp/$alias
    asadmin create-password-alias --passwordfile /tmp/$alias ${alias}_password_alias
    rm /tmp/$alias
  else
    echo "WARNING: Could not find 'password' secret for ${alias} in ${SECRETS_DIR}. Check your Kubernetes Secrets and their mounting!"
  fi
done

# 1b. Create AWS access credentials when storage driver is set to s3
# Find all access keys
if [ -d "${SECRETS_DIR}/s3" ]; then
  S3_KEYS=`find "${SECRETS_DIR}/s3" -readable -type f -iname '*access-key'`
  S3_CRED_FILE=${HOME_DIR}/.aws/credentials
  mkdir -p `dirname "${S3_CRED_FILE}"`
  rm -f ${S3_CRED_FILE}
  # Iterate keys
  while IFS= read -r S3_ACCESS_KEY; do
    echo "Loading S3 key ${S3_ACCESS_KEY}"
    # Try to find the secret key, parse for profile and add to the credentials file.
    S3_PROFILE=`echo "${S3_ACCESS_KEY}" | sed -ne "s#.*/\(.*\)-access-key#\1#p"`
    S3_SECRET_KEY=`echo "${S3_ACCESS_KEY}" | sed -ne "s#\(.*/\|.*/.*-\)access-key#\1secret-key#p"`

    if [ -r ${S3_SECRET_KEY} ]; then
      [ -z "${S3_PROFILE}" ] && echo "[default]" >> "${S3_CRED_FILE}" || echo "[${S3_PROFILE}]" >> "${S3_CRED_FILE}"
      cat "${S3_ACCESS_KEY}" | sed -e "s#^#aws_access_key_id = #" -e "s#\$#\n#" >> "${S3_CRED_FILE}"
      cat "${S3_SECRET_KEY}" | sed -e "s#^#aws_secret_access_key = #" -e "s#\$#\n#" >> "${S3_CRED_FILE}"
      echo "" >> "${S3_CRED_FILE}"
    else
      echo "ERROR: Could not find or read matching \"$S3_SECRET_KEY\"."
      exit 1
    fi
  done <<< "${S3_KEYS}"
fi

# 2. Domain-spaced resources (JDBC, JMS, ...)

# JMS
echo "Creating JMS resources."
asadmin delete-connector-connection-pool --cascade=true jms/__defaultConnectionFactory-Connection-Pool
asadmin create-connector-connection-pool \
          --steadypoolsize 1 \
          --maxpoolsize 250 \
          --poolresize 2 \
          --maxwait 60000 \
          --raname jmsra \
          --connectiondefinition javax.jms.QueueConnectionFactory \
          jms/IngestQueueConnectionFactoryPool
asadmin create-connector-resource \
          --poolname jms/IngestQueueConnectionFactoryPool \
          --description "ingest connector resource" \
          jms/IngestQueueConnectionFactory
asadmin create-admin-object \
          --restype javax.jms.Queue \
          --raname jmsra \
          --description "sample administered object" \
          --property Name=DataverseIngest \
          jms/DataverseIngest

# JDBC
echo "Creating JDBC resources."
asadmin create-jdbc-connection-pool \
          --restype javax.sql.DataSource \
          --datasourceclassname org.postgresql.ds.PGPoolingDataSource \
          --property create=true:User=${POSTGRES_USER}:PortNumber=${POSTGRES_PORT}:databaseName=${POSTGRES_DATABASE}:ServerName=${POSTGRES_SERVER} \
          dvnDbPool
asadmin set resources.jdbc-connection-pool.dvnDbPool.property.password='${ALIAS=db_password_alias}'
asadmin create-jdbc-resource --connectionpoolid dvnDbPool jdbc/VDCNetDS

# JavaMail
echo "Configuring JavaMail."
asadmin create-javamail-resource \
          --mailhost "${MAIL_SERVER}" \
          --mailuser "dataversenotify" \
          --fromaddress "${MAIL_FROMADDRESS}" \
          mail/notifyMailSession

echo "Setting miscellaneous configuration options."
# Timer data source
asadmin set configs.config.server-config.ejb-container.ejb-timer-service.timer-datasource=jdbc/VDCNetDS
# AJP connector
asadmin create-network-listener --protocol http-listener-1 --listenerport 8009 --jkenabled true jk-connector
# Disable logging for grizzly SSL problems
asadmin set-log-levels org.glassfish.grizzly.http.server.util.RequestUtils=SEVERE
# COMET support
asadmin set server-config.network-config.protocols.protocol.http-listener-1.http.comet-support-enabled="true"
# SAX parser options
asadmin create-jvm-options "\-Djavax.xml.parsers.SAXParserFactory=com.sun.org.apache.xerces.internal.jaxp.SAXParserFactoryImpl"
# Set Max Heap Space (see also https://www.eclipse.org/openj9/docs/xxinitialrampercentage)
asadmin create-jvm-options "\-XX\:+UseContainerSupport:\-Xss${MEM_XSS}:\-XX\:MaxRAMPercentage=${MEM_MAX_RAM_PERCENTAGE}"
# If configured, enable Prometheus JMX agent
# 3. Enable JDWP (debugger)
if [ "x${ENABLE_JMX_EXPORT}" = "x1" ]; then
  echo "Enabling Prometheus JMX Exporter Java Agent on port ${JMX_EXPORTER_PORT} and config at ${JMX_EXPORTER_CONFIG}."
  asadmin create-jvm-options "\-javaagent\:${HOME}/jmx_exporter_agent.jar=${JMX_EXPORTER_PORT}\:${JMX_EXPORTER_CONFIG}"
fi

# 3. Domain based configuration options
# Set Dataverse environment variables
echo "Setting system properties for Dataverse configuration options:"
env | grep -Ee "^(dataverse|doi)_" | sort -fd
env -0 | grep -z -Ee "^(dataverse|doi)_" | while IFS='=' read -r -d '' k v; do
    # transform __ to -
    KEY=`echo "${k}" | sed -e "s#__#-#g"`
    # transform remaining single _ to .
    KEY=`echo "${KEY}" | tr '_' '.'`

    # escape colons in values
    v=`echo "${v}" | sed -e 's/:/\\\:/g'`

    echo "Handling ${KEY}=${v}."
    asadmin delete-jvm-options "-D${KEY}"
    asadmin create-jvm-options "-D${KEY}=${v}"
done

# 4. Stop the domain again (will be started in foreground later)
asadmin stop-domain

# 5. Symlink the WAR file to autodeploy on real start
ln -s ${HOME_DIR}/dvinstall/dataverse.war ${DOMAIN_DIR}/autodeploy/dataverse.war

# 6. Symlink the jHove configuration
ln -s ${HOME_DIR}/dvinstall/jhove.conf ${DOMAIN_DIR}/config/jhove.conf
ln -s ${HOME_DIR}/dvinstall/jhoveConfig.xsd ${DOMAIN_DIR}/config/jhoveConfig.xsd
sed -i ${DOMAIN_DIR}/config/jhove.conf -e "s:/usr/local/glassfish4/glassfish/domains/domain1:${DOMAIN_DIR}:g"
