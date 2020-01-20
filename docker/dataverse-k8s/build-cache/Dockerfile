# Copyright 2019 Forschungszentrum Jülich GmbH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

############# BUILDCACHE FOR DATAVERSE DEV #############

FROM maven:3.5-jdk-8 as builder
# copy the project files
COPY dataverse/local_lib ./local_lib
COPY dataverse/pom.xml ./pom.xml
# build all dependencies for offline use
RUN mvn de.qaware.maven:go-offline-maven-plugin:resolve-dependencies
