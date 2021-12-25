#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh

echo "Version: ${VERSION}"

PKGS=$(ls /var/cache/pkgupd/recipes/ | sed 's|.yml||g')

echo "Generating package dependency tree"
DEPS=$(pkgupd deptest ${PKGS})
if [[ $? != 0 ]] ; then
    echo "${DEPS}"
    exit 1
fi

# TODO: must be in bootstrap
pkgupd in patch cmake meson

echo "Dependencies: ${DEPS}"

for i in /var/cache/pkgupd/recipes/*.yml ; do
    id=$(head -n1 ${i} | awk '{print $2}')
    version=$(head -n2 ${i} | tail -n1 | awk '{print $2}')
    if [[ -e /var/cache/pkgupd/pkgs/${id}-${version}.rlx ]] ; then
        echo "Skipping ${i}"
        continue
    fi
    echo "Compiling $(basename ${i})"
    pkgupd co ${i} | tee /logs/${id}-build-$(date '+%Y-%m-%d-%H').log
done