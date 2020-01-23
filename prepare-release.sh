#!/bin/bash

### +++ ### +++ ### +++ ### +++ ### +++ ### +++ ### +++ ### +++ ###
# This script looks up the latest tag, searches and replaces
# every occurence in files with the given new release number.
### +++ ### +++ ### +++ ### +++ ### +++ ### +++ ### +++ ### +++ ###

set -euo pipefail

# get numbers from cmdline or latest tag
CURRENT=`echo "${2:-$(git describe --tag --abbrev=0)}" | tr -d "v"`
NEW=`echo ${1:-${CURRENT}} | tr -d "v"`

# find all relevant files and replace inline with sed
find ./*.rst ./*.yaml ./docs ./k8s ./docker -type f \
    -not -path "./docs/release-notes/*" \
    -not -iname "*.svg" \
    -exec sed -i -e "s#${CURRENT}#${NEW}#g" {} \;
