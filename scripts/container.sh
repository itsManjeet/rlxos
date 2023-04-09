#!/bin/bash

CONTAINER_IMAGE='itsmanjeet/devel-docker:2200-3'
CONTAINER_NAME='rlxos-devel'
CONTAINER=${CONTAINER:-'podman'}

if [[ ! -z ${REMOVE_CONTAINER} ]]; then
  podman container rm rlxos-devel
fi

if [ ! "$(${CONTAINER} ps -q -f name=${CONTAINER_NAME})" ] ; then
    if [ "$(${CONTAINER} ps -aq -f status=exited -f name=${CONTAINER_NAME})" ] ; then
      ${CONTAINER} start ${CONTAINER_NAME}
    else
      echo "=> creating container"
      ${CONTAINER} run --privileged -it -d --name ${CONTAINER_NAME}  \
        -v "${PWD}":/rlxos                              \
        -v "${PWD}/pkgupd.yml:/etc/pkgupd.yml"          \
        -v "${PWD}"/storage:/storage                    \
        -v "${PWD}/sources:/sources"                    \
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