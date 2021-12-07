#!/bin/sh

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"


. ${BASEDIR}/common.sh

PROFILE=${1}

echo "Version: ${VERSION}"
echo "Profile: ${PROFILE}"

if [[ -z ${PROFILE} ]] ; then
    echo "Error! no profile specified"
    exit 1
fi

if [[ ! -e "/profiles/${PROFILE}" ]] ; then
    echo "No profile found for ${PROFILE}"
    exit 1
fi

PKGS=$(cat /profiles/${PROFILE})

ROOTFS="${BASEDIR}/rootfs"
GenerateRootfs ${PKGS}
if [[ $? != 0 ]] ; then
    echo "Error! failed to generate rootfilesystem"
    exit 1
fi

