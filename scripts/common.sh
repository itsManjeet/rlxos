#!/bin/sh

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/../"

CONTAINER_VERSION='2200-031722164'
SERVER_URL='https://apps.rlxos.dev'

if [[ -z "${NOCONTAINER}" ]]; then
    if [[ ! -e ${BASEDIR}/.version ]]; then
        echo "Error! no version specified"
        exit 1
    fi
    if [[ -z ${NO_INPUT} ]] ; then
        EXTRA_FLAGS='-i'
    fi
    STORAGE_DIR=${STORAGE_DIR:-${BASEDIR}/build}
    VERSION=$(cat ${BASEDIR}/.version)
    docker run \
        --rm \
        --network host \
        --device /dev/fuse \
        --cap-add SYS_ADMIN \
        --security-opt apparmor:unconfined \
        -v "${BASEDIR}/scripts:/scripts" \
        -v "${STORAGE_DIR}/${VERSION}/recipes:/var/cache/pkgupd/recipes" \
        -v "${STORAGE_DIR}/${VERSION}/pkgs:/var/cache/pkgupd/pkgs" \
        -v "${STORAGE_DIR}/sources:/var/cache/pkgupd/src" \
        -v "${STORAGE_DIR}/${VERSION}/logs:/logs" \
        -v "${STORAGE_DIR}/${VERSION}/releases:/releases" \
        -v "${BASEDIR}/files:/var/cache/pkgupd/files" \
        -v "${BASEDIR}/profiles:/profiles" \
        -v "${BASEDIR}/pkgupd.yml:/etc/pkgupd.yml" \
        -v /var/run/docker.sock:/var/run/docker.sock \
        ${EXTRA_FLAGS} --privileged \
        -t itsmanjeet/rlxos-devel:${CONTAINER_VERSION} /usr/bin/env -i \
        HOME=/root \
        TERM=${TERM} \
        PS1='(container) \u:\w$ ' \
        PATH='/usr/bin:/opt/bin:/apps' \
        NOCONTAINER=1 \
        SERVER_URL=${SERVER_URL} \
        VERSION=${VERSION} "/scripts/$(basename ${0})" ${@}
    exit $?
fi

# GenerateRootfs <pkgs>
# Generate root filesystem ${ROOTFS} using installed all <pkgs>
function GenerateRootfs() {
    temp_config=$(mktemp /tmp/pkgupd.XXXXXX)
    echo "RootDir: ${ROOTFS}
SystemDatabase: ${ROOTFS}/var/lib/pkgupd/data" > ${temp_config}
    pkgupd in ${@} --config ${temp_config} --no-ask --no-triggers
    ret=${?}
    rm ${temp_config}
    
    return ${ret}
}

function BoltSendMesg() {
    # if [[ -z "${NOCONTAINER}" ]]; then
    #     echo "${@}" >${BASEDIR}/discord-bolt
    # else
    #     echo ${@} >/bolt
    # fi

    echo "${@}"
}
