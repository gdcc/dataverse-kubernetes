#!/bin/sh
KUBEVAL_RELEASE=0.7.3
PLATFORM=linux

if [ ! -x test/kubeval ]; then
  echo Downloading and extracting kubeval... Please be patient.
  wget -q -O test/kubeval.tar.gz https://github.com/garethr/kubeval/releases/download/${KUBEVAL_RELEASE}/kubeval-${PLATFORM}-amd64.tar.gz
  tar xf test/kubeval.tar.gz -C test
fi

find k8s -name '*.yaml' -print0 | xargs -0 test/kubeval
