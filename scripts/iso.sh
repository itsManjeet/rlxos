#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh

if [[ -z ${1} ]]; then
    echo "Error! no profile specified"
    exit 1
fi

PROFILE="/profiles/${VERSION}/${1}"

if [[ ! -e ${PROFILE} ]] ; then
    echo "Error! '${PROFILE}' profile not exists"
    exit 1
fi

PKGS=$(cat ${PROFILE})
if [[ -z ${PKG} ]] ; then
    echo "Error! no package found in ${PROFILE}"
    exit 1
fi

echo "preparing ISO ${PROFILE}"
export ROOTFS=/tmp/rlxos-rootfs
GenerateRootfs ${PKGS}
if [[ $? -ne 0 ]] ; then
  echo "rootfs build failed ${?}"
  exit 1
fi

ISODIR=/tmp/rlxos-iso

mkdir -p ${ISODIR}/boot/grub/

mksquashfs ${ROOTFS}/* ${ISODIR}/rootfs.img
cp ${ROOTFS}/boot/vmlinuz ${ISODIR}/boot/
mkinitramfs -g -k=$(ls /lib/modules) -o=${ISODIR}/boot/initrd

echo "default='rlxos installer'
timeout=5
menuentry 'rlxos installer' {
    linux /boot/vmlinuz iso=1 root=LABEL=RLXOS system=${VERSION} iso=1
    initrd /boot/initrd
}" > ${ISODIR}/boot/grub/grub.cfg

grub-mkrescue -volid RLXOS ${ISODIR} -o /releases/rlxos-$(basename ${PROFILE})-${VERSION}.iso



