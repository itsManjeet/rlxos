#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/../"

VERSION=$(cat ${BASEDIR}/.version)
PKGDIR="${BASEDIR}/build/${VERSION}/pkgs"
RECIPEDIR="${BASEDIR}/build/${VERSION}/recipes"

${BASEDIR}/scripts/configure.py
echo "version: ${VERSION}
recipes:" >${PKGDIR}/recipe
for i in ${RECIPEDIR}/*.yml; do
    head -n1 ${i} | sed 's/^/  - /' >>${PKGDIR}/recipe
    tail -n+2 ${i} | sed 's/^/    /' >>${PKGDIR}/recipe
    if [[ ${?} -ne 0 ]]; then
        echo "Error! failed to register ${i}"
        continue
    fi
    echo "" >> ${PKGDIR}/recipe
done
source ./secure/storage

rm -rf ${RECIPEDIR}

lftp -e "
set ftp:ssl-allow no
open ${STORAGE_URL}
user ${STORAGE_USERNAME} ${STORAGE_PASSWORD}
mirror --reverse --verbose ${BASEDIR}/build/ ${STORAGE_PATH}/
bye
"
