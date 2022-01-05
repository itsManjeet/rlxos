#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/../"

VERSION=$(cat ${BASEDIR}/.version)
PKGDIR="${BASEDIR}/build/${VERSION}/pkgs"
echo "version: ${VERSION}
recipes:" >${PKGDIR}/recipe
for i in ${PKGDIR}/*.rlx; do
    head_id="  - $(tar -xf ${i} ./info -O | head -n1)"
    echo "${head_id}" >>${PKGDIR}/recipe
    echo "    type: package" >>${PKGDIR}/recipe
    tar -xf ${i} ./info -O | tail -n+2 | sed 's/^/    /' >>${PKGDIR}/recipe
    if [[ ${?} -ne 0 ]]; then
        echo "Error! failed to register ${i}"
        continue
    fi
    echo "    packages:" >> ${PKGDIR}/recipe
    echo "      - id: pkg" >> ${PKGDIR}/recipe
    echo "        pack: rlx" >> ${PKGDIR}/recipe
    echo "        dir: ." >> ${PKGDIR}/recipe
done

for i in ${PKGDIR}/*.app; do
    ${i} --appimage-extract info
    head_id="  - $(cat squashfs-root/info | head -n1)"
    echo "${head_id}" >> ${PKGDIR}/recipe
    echo "    type: app" >> ${PKGDIR}/recipe
    tail -n+2 squashfs-root/info | sed 's/^/    /' >>${PKGDIR}/recipe
    echo "    packages:" >> $PKGDIR/recipe
    echo "      - id: pkg" >> ${PKGDIR}/recipe
    echo "        pack: app" >> ${PKGDIR}/recipe
    echo "        dir: ." >> ${PKGDIR}/recipe

    rm -rf squashfs-root
done
source ./secure/storage

lftp -e "
set ftp:ssl-allow no
open ${STORAGE_URL}
user ${STORAGE_USERNAME} ${STORAGE_PASSWORD}
mirror --reverse --verbose ${BASEDIR}/build/ ${STORAGE_PATH}/
bye
"
