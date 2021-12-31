#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh

echo "Version: ${VERSION}"

PKG=${1}
if [[ -z ${1} ]]; then
    echo "Error! no package specified"
    exit 1
fi

pkgupd in kernel-headers cmake binutils flex bison autoconf automake make patch pkg-config gperf

DEPS=$(pkgupd deptest ${PKG} --force)
if [[ ${?} != 0 ]]; then
    echo "Error! failed to calculate depends"
    exit 1
fi

if [[ -z "${DEPS}" ]]; then
    DEPS="${PKG} "
fi

echo "Compiling dependencies ${DEPS}"
for i in ${DEPS}; do
    echo "compiling ${i}"
    [[ ${i} == "${PKG}" ]] && PKGUPD_FLAG="--force"
    echo "pkgupd co ${i} ${PKGUPD_FLAG}"
    pkgupd co ${i} ${PKGUPD_FLAG}
    if [[ ${?} != 0 ]]; then
        echo "Error! failed to compile ${i}"
        exit 1
    fi
done
