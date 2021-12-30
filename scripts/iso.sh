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

if [[ ! -d ${PROFILE} ]] ; then
    echo "Error! '${PROFILE}' profile not exists"
    exit 1
fi

BoltSendMesg "Generating ISO for ${VERSION} with $(basename ${PROFILE})"

PKGS=$(cat ${PROFILE}/pkgs)
if [[ -z ${PKGS} ]] ; then
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

SCRIPT=$(cat ${PROFILE}/script)

chroot ${ROOTFS} bash -e << "EOT"
pwconv
grpconv

pkgupd trigger
echo -e "rlxos\nrlxos" | passwd
${SCRIPT}
EOT

ISODIR=/tmp/rlxos-iso

pkgupd in grub-legacy grub squashfs-tools lvm2 initramfs mtools linux 
mkdir -p ${ISODIR}/boot/grub/

mksquashfs ${ROOTFS}/* ${ISODIR}/rootfs.img
cp ${ROOTFS}/boot/vmlinuz ${ISODIR}/boot/
mkinitramfs -g -k=$(ls ${ROOTFS}/lib/modules) -o=${ISODIR}/boot/initrd

echo "default='rlxos installer'
timeout=5
menuentry 'rlxos installer' {
    linux /boot/vmlinuz iso=1 root=LABEL=RLXOS system=${VERSION} iso=1
    initrd /boot/initrd
}" > ${ISODIR}/boot/grub/grub.cfg

ISOFILE="/releases/rlxos-$(basename ${PROFILE})-${VERSION}.iso"
grub-mkrescue -volid RLXOS ${ISODIR} -o ${ISOFILE}

BoltSendMesg "[TESTING ISO] generated at ${SERVER_URL}/${VERSION}${ISOFILE}" > /bolt