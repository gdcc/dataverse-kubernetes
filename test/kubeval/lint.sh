#!/bin/sh
K8S_RELEASE=${K8S_RELEASE:-${1-1.14.6}}
KUBEVAL_DIR=${KUBEVAL_DIR:-"test/kubeval"}

echo "Running kubeval with schema for k8s v${K8S_RELEASE}"

find k8s -name '*.yaml' ! -name 'kustomization.yaml' -print0 | xargs -0 "${KUBEVAL_DIR}/kubeval" -v ${K8S_RELEASE}
status_k8s=$?

find docs -name '*.yaml' ! -name 'kustomization.yaml' ! -name 'patch*.yaml' -print0 | xargs -0 "${KUBEVAL_DIR}/kubeval" -v ${K8S_RELEASE}
status_docs=$?

if [ "$status_k8s" = 0 ] && [ "$status_docs" = 0 ] ; then
    echo "Static analysis found no problems."
    exit 0
else
    echo 1>&2 "Static analysis found violations that need to be fixed."
    exit 1
fi
