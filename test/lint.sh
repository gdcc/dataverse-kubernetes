#!/bin/sh
KUBEVAL_RELEASE=0.10.0
PLATFORM=linux
K8S_RELEASE=${K8S_RELEASE:-${1-1.13.0}}

if [ ! -x test/kubeval ] || [ ! -f test/kubeval-${KUBEVAL_RELEASE}.tar.gz ]; then
  echo Downloading and extracting kubeval-${KUBEVAL_RELEASE}... Please be patient.
  # delete old releases
  rm -f test/kubeval*
  # download new
  wget -q -O test/kubeval-${KUBEVAL_RELEASE}.tar.gz https://github.com/garethr/kubeval/releases/download/${KUBEVAL_RELEASE}/kubeval-${PLATFORM}-amd64.tar.gz
  tar xf test/kubeval-${KUBEVAL_RELEASE}.tar.gz -C test kubeval
fi

echo "Running kubeval with schema for k8s v${K8S_RELEASE}"

find k8s -name '*.yaml' ! -name 'kustomization.yaml' -print0 | xargs -0 test/kubeval -v ${K8S_RELEASE}
status_k8s=$?

find docs -name '*.yaml' ! -name 'kustomization.yaml' ! -name 'patch*.yaml' -print0 | xargs -0 test/kubeval -v ${K8S_RELEASE}
status_docs=$?

if [ "$status_k8s" = 0 ] || [ "$status_docs" = 0 ] ; then
    echo "Static analysis found no problems."
    exit 0
else
    echo 1>&2 "Static analysis found violations that need to be fixed."
    exit 1
fi
