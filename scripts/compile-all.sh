#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

VERSION=$(cat ${BASEDIR}/.version)

PKGS=$(ls ${BASEDIR}/build/${VERSION}/recipes/ | sed 's|.yml||g')

for pkg in ${PKGS}; do
    echo "compiling for ${pkg}"
    LOGFILE="${BASEDIR}/build/${VERSION}/logs/${pkg}.log"
    ${BASEDIR}/compile.sh ${pkg} | tee ${LOGFILE}
    if [[ ${?} != 0 ]]; then
        echo "Failed to compile ${pkg}"
        mv "${LOGFILE}" "${LOGFILE}.failed"
    fi
done
