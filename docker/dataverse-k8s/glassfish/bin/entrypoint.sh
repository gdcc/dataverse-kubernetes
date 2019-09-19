#!/bin/bash

# Run init scripts (credits go to MySQL Docker entrypoint script)
for f in ${SCRIPT_DIR}/init_* ${SCRIPT_DIR}/init.d/*; do
      case "$f" in
        *.sh)  echo "[Entrypoint] running $f"; . "$f" ;;
        *)     echo "[Entrypoint] ignoring $f" ;;
      esac
      echo
done

# "--verbose" starts the domain in foreground using Glassfish 4.1
# TODO: It would be better to follow the Payara approach and execute the JVM
#       directly to avoid a doubled JVM, but this seems impossible with
#       a "vanilla" Glassfish 4.1 (the appserver simply doesn't start).
#       Maybe using a Payara 4.x appserver can help with this.
exec ${GLASSFISH_DIR}/bin/asadmin start-domain --verbose
