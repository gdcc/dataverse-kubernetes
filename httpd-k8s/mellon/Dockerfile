# Copyright 2019 Forschungszentrum Jülich GmbH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

FROM httpd:2.4 AS builder

ARG MELLON_VERSION=0.14.1
ARG MELLON_URL=https://github.com/Uninett/mod_auth_mellon/releases/download/v${MELLON_VERSION}/mod_auth_mellon-${MELLON_VERSION}.tar.gz
ARG MELLON_SHA256=9e2d956cf9c61ddbd3820920b56aaa5cf59217b3864dc69a640c8b312e2659a9

# Setup build dependencies
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    gcc \
    libssl-dev \
    liblasso3-dev \
    libcurl4-openssl-dev \
    make \
    wget

# Compile mod_auth_mellon
WORKDIR /tmp
RUN set -eux; \
  wget -O mod_auth_mellon.tar.gz ${MELLON_URL}; \
  echo "$MELLON_SHA256 *mod_auth_mellon.tar.gz" | sha256sum -c -; \
  tar -xzf mod_auth_mellon.tar.gz -C .; \
  cd mod_auth_mellon-${MELLON_VERSION}; \
  ./configure --with-apxs2=${HTTPD_PREFIX}/bin/apxs; \
  make; \
  make install; \
  mv mellon_create_metadata.sh ${HTTPD_PREFIX}/bin/

FROM httpd:2.4
LABEL maintainer="FDM FZJ <forschungsdaten@fz-juelich.de>"

# Copy build artifacts
COPY --from=builder ${HTTPD_PREFIX}/modules/mod_auth_mellon.so ${HTTPD_PREFIX}/modules/
COPY --from=builder ${HTTPD_PREFIX}/bin/mellon_create_metadata.sh ${HTTPD_PREFIX}/bin/

# Install runtime dependencies and load the module in httpd.conf
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    liblasso3 \
    libcurl3 \
    ca-certificates \
  ; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  mkdir ${HTTPD_PREFIX}/conf/k8s; \
  echo "IncludeOptional conf/k8s/*.conf" >> ${HTTPD_PREFIX}/conf/httpd.conf; \
  apxs -e -a -n auth_mellon ${HTTPD_PREFIX}/modules/mod_auth_mellon.so; \
  httpd -v
