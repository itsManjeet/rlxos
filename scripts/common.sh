#!/bin/sh

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/../"

if [[ -z "${NOCONTAINER}" ]]; then
    VERSION=$(cat ${BASEDIR}/.version)

    echo "Starting container"
    docker run \
        --rm \
        --network host \
        -v "${BASEDIR}/scripts:/scripts" \
        -v "${BASEDIR}/build/${VERSION}/recipes:/var/cache/pkgupd/recipes" \
        -v "${BASEDIR}/build/${VERSION}/pkgs:/var/cache/pkgupd/pkgs" \
        -v "${BASEDIR}/files:/var/cache/pkgupd/files" \
        -i --privileged \
        -t itsmanjeet/rlxos-devel:${VERSION} /usr/bin/env -i \
        HOME=/root \
        TERM=${TERM} \
        PS1='(container) \u:\w$ ' \
        PATH='/usr/bin:/opt/bin' \
        NOCONTAINER=1 \
        VERSION=${VERSION} "/scripts/$(basename ${0})"
    exit $?
fi
