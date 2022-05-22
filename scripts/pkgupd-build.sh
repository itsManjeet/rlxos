#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh


echo "installing pkgupd"
DEBUG=1 pkgupd in pkgupd --force --no-depends

for i in ${@} ; do
    pkgupd build build.recipe=/var/cache/pkgupd/${i} package.repository=$(echo ${i} | cut -d '/' -f2)
    if [[ $? != 0 ]] ; then
        echo "Error! failed to build ${i}"
        exit 1
    fi
done