#!/bin/bash

ID=${1}
SOURCE_FILE=${2}

CONTAINER=${CONTAINER:-'docker'}

[[ -z ${SOURCE_FILE} ]] && {
    echo "Usage: ${0} <ID> <SOURCE_FILE>"
    exit 1
}

echo "=> creating container ${ID} from ${SOURCE_FILE}"
unzstd --stdout ${SOURCE_FILE} | ${CONTAINER} import - ${ID}
if [[ $? -ne 0 ]] ; then
    echo "FAILED to create container with id ${ID}"
    exit 1
fi

echo "SUCCESS: ${ID} is ready to use"