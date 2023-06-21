#!/bin/bash

CONTAINER_IMAGE='itsmanjeet/devel-docker:2300-2'
CONTAINER_NAME='devel-docker'
CONTAINER=${CONTAINER:-'docker'}

if [[ ! -z ${REMOVE_CONTAINER} ]]; then
    ${CONTAINER} container rm ${CONTAINER_NAME}
fi

if [ ! "$(${CONTAINER} ps -q -f name=${CONTAINER_NAME})" ] ; then
    if [ "$(${CONTAINER} ps -aq -f status=exited -f name=${CONTAINER_NAME})" ] ; then
        ${CONTAINER} start ${CONTAINER_NAME}
    else
        echo "=> creating container"
        ${CONTAINER} run --privileged -it -d --name ${CONTAINER_NAME}  \
        -v "${PWD}":/rlxos                              \
        -v "${PWD}/pkgupd.yml:/etc/pkgupd.yml"          \
        -v "${PWD}"/build/storage:/storage              \
        -v "${PWD}/build/sources:/sources"              \
        -v "${PWD}/files:/files"                        \
        -w /rlxos                                       \
        -e PATH=/rlxos/bin:/usr/bin:/opt/bin            \
        -e PS1='(rlxos) \W \$ '                         \
        --net=host                                      \
        -e HOME=/                                       \
        ${CONTAINER_IMAGE}  /bin/bash
    fi
fi

if [ ! "$(${CONTAINER} ps -q -f name=${CONTAINER_NAME})" ] ; then
    ${CONTAINER} start ${CONTAINER_NAME}
fi

${CONTAINER} attach ${CONTAINER_NAME}