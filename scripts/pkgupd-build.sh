#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh
export PKGUPD_NO_PROGRESS=1

echo "updating system"
pkgupd update mode.ask=false

for i in ${@} ; do
    DEBUG=1 pkgupd build build.recipe=/var/cache/pkgupd/${i} package.repository=$(echo ${i} | cut -d '/' -f2) mode.ask=false
    if [[ $? != 0 ]] ; then
        echo "Error! failed to build ${i}"
        exit 1
    fi
done