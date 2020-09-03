#!/bin/bash

set -e

###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
# This script enables different development options, like a JMX connector
# usable with VisualVM, JRebel hot-reload support and JDWP debugger service.
# Enable it by adding env vars on startup (e.g. via ConfigMap)
###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######

# 0. Init variables
ENABLE_JMX=${ENABLE_JMX:-0}
ENABLE_JDWP=${ENABLE_JDWP:-0}
ENABLE_JREBEL=${ENABLE_JREBEL:-0}
JDWP_PORT=${JDWP_PORT:-9009}

# 1. if any options need to be set, start the server...
if [ "x${ENABLE_JMX}" = "x1" ] ||  [ "x${ENABLE_JDWP}" = "x1" ] || [ "x${ENABLE_JREBEL}" = "x1" ]; then
  echo "Starting application server..."
  asadmin start-domain
fi

# 2. Enable JMX (metrics + performance)
if [ "x${ENABLE_JMX}" = "x1" ]; then
  echo "Enabling JMX Remote on port 4000/4001. Remember you need to connect to localhost, e.g. via port-forwarding."
  asadmin create-jvm-options "\-Dcom.sun.management.jmxremote"
  asadmin create-jvm-options "\-Dcom.sun.management.jmxremote.port=4000"
  asadmin create-jvm-options "\-Dcom.sun.management.jmxremote.rmi.port=4001"
  asadmin create-jvm-options "\-Dcom.sun.management.jmxremote.ssl=false"
  asadmin create-jvm-options "\-Dcom.sun.management.jmxremote.authenticate=false"
  asadmin create-jvm-options "\-Djava.rmi.server.hostname=127.0.0.1"
fi

# 3. Enable JDWP (debugger)
if [ "x${ENABLE_JDWP}" = "x1" ]; then
  echo "Enabling JDWP debugger, listening on port ${JDWP_PORT} of this container/pod."
  asadmin create-jvm-options "\-agentlib\:jdwp=transport=dt_socket,server=y,suspend=n,address=${JDWP_PORT}"
fi

# 4. Enable JRebel (hot-redeploy)
if [ "x${ENABLE_JREBEL}" = "x1" ] && [ -s "${JREBEL_LIB}" ]; then
  echo "Enabling JRebel support with enabled remoting_plugin option."
  asadmin create-jvm-options "\-agentpath\:${JREBEL_LIB}"
  asadmin create-jvm-options "\-Drebel.remoting_plugin=true"
fi

# 5. Stop the server
# 1. if any options need to be set, start the server...
if [ "x${ENABLE_JMX}" = "x1" ] ||  [ "x${ENABLE_JDWP}" = "x1" ] || [ "x${ENABLE_JREBEL}" = "x1" ]; then
  echo "Stopping application server..."
  asadmin stop-domain
fi
