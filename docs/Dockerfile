# Copyright 2019 Forschungszentrum Jülich GmbH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

FROM python:3.7-alpine
LABEL maintainer="FDM FZJ <forschungsdaten@fz-juelich.de>"

RUN apk --no-cache add openjdk8-jre graphviz curl ttf-dejavu && \
    curl -sS -f -Lo /usr/local/bin/plantuml.jar https://sourceforge.net/projects/plantuml/files/plantuml.jar/download && \
    echo -e '#!/bin/sh\n\
java -jar /usr/local/bin/plantuml.jar "$@"' >> /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
