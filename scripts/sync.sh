#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/../"

VERSION=$(cat ${BASEDIR}/.version)
PKGDIR="${BASEDIR}/build/${VERSION}/pkgs"
echo "version: ${VERSION}
recipes:" > ${PKGDIR}/recipe
for i in ${PKGDIR}/*.rlx ; do
    head_id="  - $(tar -xf ${i} ./info -O | head -n1)"
    echo "${head_id}" >> ${PKGDIR}/recipe
    tar -xf ${i} ./info -O | tail -n+2 | sed 's/^/    /' >> ${PKGDIR}/recipe
    if [[ ${?} -ne 0 ]] ; then
        echo "Error! failed to register ${i}"
        continue
    fi
done
source ./secure/storage

lftp -e "
set ftp:ssl-allow no
open ${STORAGE_URL}
user ${STORAGE_USERNAME} ${STORAGE_PASSWORD}
mirror --reverse --verbose ${BASEDIR}/build/ ${STORAGE_PATH}/
bye
"
