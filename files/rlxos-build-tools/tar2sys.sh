#!/bin/bash

TARFILE=${1}
OUTPUTFILE=${2}

if [[ -z ${OUTPUTFILE} ]] ; then
    echo "Usage: ${0} <tarfile> <output>"
    exit 1
fi


TEMPDIR=$(mktemp -d /tmp/workdir-XXXXXXXXXX)

echo "=> extracting tar file into ${TEMPDIR}"
tar -xaf ${TARFILE} -C ${TEMPDIR} || {
    echo "Error! failed to extract tar file"
    rm -rf ${TEMPDIR}
    exit 1
}

echo "=> generating squashfs image ${OUTPUTFILE}"
mksquashfs ${TEMPDIR} ${OUTPUTFILE} \
    -comp zstd \
    -Xcompression-level 12 \
    -noappend || {
        echo "Error! failed to compression system image"
        rm -rf ${TEMPDIR}
        exit 1
    }

echo ":: system image generated successfully ${OUTPUTFILE} ::"
