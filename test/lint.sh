#!/bin/sh
KUBEVAL_RELEASE=0.7.3
PLATFORM=linux
K8S_RELEASE=${K8S_RELEASE:-${1-1.13.0}}

if [ ! -x test/kubeval ]; then
  echo Downloading and extracting kubeval... Please be patient.
  wget -q -O test/kubeval.tar.gz https://github.com/garethr/kubeval/releases/download/${KUBEVAL_RELEASE}/kubeval-${PLATFORM}-amd64.tar.gz
  tar xf test/kubeval.tar.gz -C test
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
