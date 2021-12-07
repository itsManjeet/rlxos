#!/bin/sh

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

echo "Dependencies: ${DEPS}"

for i in /var/cache/pkgupd/recipes/*.yml ; do
    echo "Compiling $(basename ${i})"
    pkgupd co ${i}
done