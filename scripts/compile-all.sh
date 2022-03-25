#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/../"

VERSION=$(cat ${BASEDIR}/.version)
${BASEDIR}/scripts/configure.py

PKGS=$(ls ${BASEDIR}/build/${VERSION}/recipes/core/ | sed 's|.yml||g')

DEPENDS_FILE="${BASEDIR}/build/depends"

if [[ -f ${DEPENDS_FILE} ]] ; then
    DEPENDS=$(cat ${DEPENDS_FILE})
else
    DEPENDS=$(${BASEDIR}/scripts/exec.sh pkgupd depends ${PKGS} --force 2>&1)
    if [[ $? != 0 ]] ; then
        echo "Failed to calculate dependencies ${DEPENDS}"
        exit 1
    fi
    echo "${DEPENDS}" > ${DEPENDS_FILE}
fi

for pkg in ${DEPENDS}; do
    # BoltSendMesg "compiling for ${pkg}"
    LOGFILE="${BASEDIR}/build/${VERSION}/logs/${pkg}.log"
    ${BASEDIR}/scripts/exec.sh pkgupd co ${pkg} 2>&1 | sed -r 's/\x1b\[[0-9;]*m//g' | tee ${LOGFILE}
    if [[ ${PIPESTATUS[0]} != 0 ]]; then
        # BoltSendMesg "Failed to compile ${pkg}"
        mv "${LOGFILE}" "${LOGFILE}.failed"
    fi

    sed -i "s#^${pkg}\b##" build/depends
done

rm build/depends
