# Copyright 2019 Forschungszentrum Jülich GmbH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

############# BUILD DATAVERSE #############

FROM maven:3.5-jdk-8 as builder
# copy the project files
COPY dataverse/local_lib ./local_lib
COPY dataverse/pom.xml ./pom.xml
# build all dependencies for offline use
RUN mvn de.qaware.maven:go-offline-maven-plugin:resolve-dependencies
# copy your other files
COPY dataverse/src ./src
# build for release (in offline mode)
RUN mvn -o package -DskipTests

############# BUILD IMAGE #############
FROM iqss/dataverse-k8s
LABEL maintainer="FDM FZJ <forschungsdaten@fz-juelich.de>"

# Copy files for the application
COPY --chown=glassfish:glassfish --from=builder /target/dataverse-*.war ${HOME_DIR}/dvinstall/dataverse.war
COPY --chown=glassfish:glassfish dataverse/scripts/api/data ${HOME_DIR}/dvinstall/data
COPY --chown=glassfish:glassfish dataverse/scripts/api/*.sh ${HOME_DIR}/dvinstall/
COPY --chown=glassfish:glassfish dataverse/scripts/database/reference_data.sql ${HOME_DIR}/dvinstall/
COPY --chown=glassfish:glassfish dataverse/conf/jhove/* ${HOME_DIR}/dvinstall/
