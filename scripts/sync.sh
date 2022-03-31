#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/../"

VERSION=$(cat ${BASEDIR}/.version)
PKGDIR="${BASEDIR}/build/${VERSION}/pkgs"
RECIPEDIR="${BASEDIR}/build/${VERSION}/recipes"

${BASEDIR}/scripts/configure.py

for repo in ${RECIPEDIR}/* ; do
    echo "version: ${VERSION}
recipes:" > ${PKGDIR}/$(basename ${repo})/recipe
    for i in ${repo}/*.yml; do
        repo=${PKGDIR}/$(basename ${repo})
        head -n1 ${i} | sed 's/^/  - /' >>${repo}/recipe
        tail -n+2 ${i} | sed 's/^/    /' >>${repo}/recipe
        if [[ ${?} -ne 0 ]]; then
            echo "Error! failed to register ${i}"
            continue
        fi
        echo "" >> ${repo}/recipe
    done
done