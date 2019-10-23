#!/bin/sh
K8S_RELEASE=${K8S_RELEASE:-${1-1.14.6}}
KUBEVAL_DIR=${KUBEVAL_DIR:-"test/kubeval"}

echo "Validating Kustomization files:"
echo "Using kubeval with schema for k8s v${K8S_RELEASE}"

find k8s personas -name 'kustomization.yaml' -print0 | xargs -0 -n1 -I "%file%" bash -c "
set -euo pipefail
dir=\`dirname %file%\`
echo \"Validating %file%...\"
${KUBEVAL_DIR}/kustomize build ${dir} | ${KUBEVAL_DIR}/kubeval -v ${K8S_RELEASE}
"
status_k8s=$?

if [ "$status_k8s" = 0 ]; then
    echo "Static analysis after Kustomization found no problems."
    exit 0
else
    echo 1>&2 "Static analysis after Kustomization found violations that need to be fixed."
    exit 1
fi
