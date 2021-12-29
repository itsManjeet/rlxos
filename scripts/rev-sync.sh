#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/../"

VERSION=$(cat ${BASEDIR}/.version)
PKGDIR="${BASEDIR}/build/${VERSION}/pkgs"
source ./secure/storage

lftp -e "
set ftp:ssl-allow no
open ${STORAGE_URL}
user ${STORAGE_USERNAME} ${STORAGE_PASSWORD}
mirror --verbose ${STORAGE_PATH}/${VERSION} ${BASEDIR}/build/
bye
"
