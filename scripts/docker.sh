#!/bin/sh

BASEDIR="$(dirname $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P ))"

_dir="${1}"
_id="${2}"

dockerfile=${BASEDIR}/docker/Dockerfile.${_id}

if [[ -z ${_dir} ]] || [[ -z ${_id} ]] ; then
    echo "Usage: <dir> <id>"
    exit 1
fi

[[ ! -d ${_dir} ]] && {
    echo "Error: ${_dir} not exist"
    exit 1
}

[[ ! -f ${dockerfile} ]] && {
    echo "Error: ${dockerfile} for ${_id} not exists"
    exit 1
}

if [[ -f ${BASEDIR}/docker/${_id}.dockerignore ]] ; then
    echo "copying docker ignore file"
    cp ${BASEDIR}/docker/${_id}.dockerignore ${_dir}/.dockerignore
fi

pushd ${_dir}
docker build -t rlxos.${_id} . -f ${dockerfile}
[[ $? -ne 0 ]] && {
    echo "Failed to pack docker image"
    exit 1
}
popd