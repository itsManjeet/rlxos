#!/bin/bash

DIR=${1}
[[ -z ${DIR} ]] && {
    echo "Usage: ${0} <dir>"
    exit 1
}

for i in ${DIR}/* ; do
    if [[ $(basename ${i}) == "meta" ]] || [[ $(basename ${i}) =~ .meta ]] ; then
        continue;
    fi
    if [[ -e ${i}.meta ]] ; then
        continue
    fi
    PACKAGE_NAME=$(PKGUPD_NO_MESSAGE=1 pkgupd info ${i} info.value=id)
    if [[ $? != 0 ]] ; then
        echo "Failed to read package information from ${i}"
        continue
    fi
    
    echo "generating data for ${PACKAGE_NAME}"
    pkgupd info ${i} info.dump="$(dirname ${i})/${PACKAGE_NAME}.meta"
done