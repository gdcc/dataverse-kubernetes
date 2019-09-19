#!/bin/bash
set -euo pipefail

KUBEVAL_DIR=${KUBEVAL_DIR:-"test/kubeval"}
KUBEVAL_RELEASE=${KUBEVAL_RELEASE:-0.14.0}
KUBEVAL_PLATFORM=${KUBEVAL_PLATFORM:-linux}
KUBEVAL_URL="https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_RELEASE}/kubeval-${KUBEVAL_PLATFORM}-amd64.tar.gz"

if [ ! -x "${KUBEVAL_DIR}/kubeval" ] || [ ! -f "${KUBEVAL_DIR}/kubeval-${KUBEVAL_RELEASE}.tar.gz" ]; then
  echo Downloading and extracting kubeval-${KUBEVAL_RELEASE}... Please be patient.
  # delete old releases
  rm -f "${KUBEVAL_DIR}/kubeval*"
  # download new
  wget -q -O "${KUBEVAL_DIR}/kubeval-${KUBEVAL_RELEASE}.tar.gz" "${KUBEVAL_URL}"
  tar xf "${KUBEVAL_DIR}/kubeval-${KUBEVAL_RELEASE}.tar.gz" -C "${KUBEVAL_DIR}" kubeval
fi
