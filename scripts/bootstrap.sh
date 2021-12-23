#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh

#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1> /logs/$(date '+%Y-%m-%d-%H').log 2>&1

echo "Version: ${VERSION}"

echo "Regenerating toolchain build"
for i in kernel-headers glibc binutils gcc binutils glibc ; do
    pkgupd co ${i} --force
    if [[ $? != 0 ]] ; then
        echo "failed to build toolchain ${i}"
        exit 1
    fi
done

echo "Generating package dependency tree"
DEPS=$(pkgupd deptest core)
if [[ $? != 0 ]] ; then
    echo "${DEPS}"
    exit 1
fi

echo "Dependencies: ${DEPS}"

for i in ${DEPS} ; do
    echo "Compiling $(basename ${i})"
    DEBUG=1 CURL_DEBUG=1 pkgupd co ${i}
    if [[ ${?} -ne 0 ]] ; then
        echo "build failed ${i}"
        exit 1
    fi
done
