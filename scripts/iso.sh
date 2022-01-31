#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh

KERNEL='5.12.10-rlxos'
FIRMWARE='20211027'

if [[ -z ${1} ]]; then
    echo "Error! no profile specified"
    exit 1
fi

PROFILE="/profiles/${VERSION}/${1}"

if [[ ! -d ${PROFILE} ]]; then
    echo "Error! '${PROFILE}' profile not exists"
    exit 1
fi

function checkProcess() {
    if [[ $? != 0 ]]; then
        BoltSendMesg "Error! while building ISO (${VERSION}:${PROFILE}) at ${@}"
        exit 1
    fi
}

BoltSendMesg "[$(date)]: generating [TEST] ISO for ${VERSION} with $(basename ${PROFILE})"

PKGS=$(cat ${PROFILE}/pkgs)
if [[ -z ${PKGS} ]]; then
    echo "Error! no package found in ${PROFILE}"
    exit 1
fi

pkgupd in grub-legacy grub squashfs-tools lvm2 initramfs mtools linux
checkProcess "InstallingTools"

# Temporary KMOD reinstallations
pkgupd in kmod --force --skip-depends
checkProcess "InstallKmod"

echo "preparing ISO ${PROFILE}"
export ROOTFS=/tmp/rlxos-rootfs
GenerateRootfs ${PKGS}
checkProcess "GenerateRootfs()"

SCRIPT=$(cat ${PROFILE}/script)
checkProcess "checkLocalScript"

echo ":: installing fstab"
echo "
/run/initramfs/boot /boot   none defaults,bind  0   0
" >${ROOTFS}/etc/fstab

chroot ${ROOTFS} bash -e <<"EOT"
pwconv
grpconv

# executing pkgupd triggers
pkgupd trigger

# setting up root password
echo -e "rlxos\nrlxos" | passwd

# set default localtime
ln -sfv /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

# setting up hostname
echo 'workstation' > /etc/hostname
EOT
checkProcess "PostExecutionScript"

echo ":: executing local script"
chroot ${ROOTFS} bash -ec "${SCRIPT}"
checkProcess "LocalScript"

# installing logo
install -v -D -m 0644 "/var/cache/pkgupd/files/logo/logo.png" -o root -g root ${ROOTFS}/usr/share/pixmaps/rlxos.png
install -v -D -m 0644 "/var/cache/pkgupd/files/backgrounds/default.png" -o root -g root ${ROOTFS}/usr/share/backgrounds/default.png
checkProcess "LogoInstall"

ISODIR=/tmp/rlxos-iso
TEMPDIR=/tmp/work
mkdir -p ${TEMPDIR}

mkdir -p ${ISODIR}/boot/grub/

mksquashfs ${ROOTFS}/* ${ISODIR}/rootfs.img
checkProcess "PackingSquash:root"

KERNEL_VERSION=$(echo ${KERNEL} | sed 's|-rlxos||g')
echo ":: installing kernel"
tar -xaf /var/cache/pkgupd/pkgs/linux-${KERNEL_VERSION}.rlx -C ${TEMPDIR} &&
    mv ${TEMPDIR}/usr/lib/modules ${ISODIR}/boot/ &&
    mv ${TEMPDIR}/boot/vmlinuz ${ISODIR}/boot/vmlinuz-${KERNEL}
checkProcess "InstallKernel"

echo "installing initrd Kernel=${KERNEL} Modules=${ISODIR}/boot/modules"
mkinitramfs -u -k=${KERNEL} -m="${ISODIR}/boot/modules/" -o=${ISODIR}/boot/initrd-${KERNEL}
checkProcess "GeneratingInitrd"

echo "default='rlxos installer'
timeout=5
menuentry 'rlxos installer' {
    linux /boot/vmlinuz-${KERNEL} iso=1 root=LABEL=RLXOS system=${VERSION}
    initrd /boot/initrd-${KERNEL}
}" >${ISODIR}/boot/grub/grub.cfg

cp -a ${PROFILE}/overlay ${TEMPDIR}/
sudo chown root:root ${TEMPDIR}/overlay -R
install -v -D /var/cache/pkgupd/files/systemd/rlxos-boot.mount -t ${TEMPDIR}/overlay/usr/lib/systemd/system


mkdir -p ${TEMPDIR}/overlay/etc
echo "
/run/iso/boot   /boot   none    defauts,bind    0   0" > ${TEMPDIR}/overlay/etc/fstab

mksquashfs ${TEMPDIR}/overlay/* ${ISODIR}/iso.img
checkProcess "PackingSquash:iso"

ISOFILE="/releases/rlxos-$(basename ${PROFILE})-${VERSION}.iso"
grub-mkrescue -volid RLXOS ${ISODIR} -o ${ISOFILE}
checkProcess "GenIso"

md5sum ${ISOFILE} >${ISOFILE}.md5
checkProcess "GenMD5"

BoltSendMesg "$(date) generated [TEST] iso at ${SERVER_URL}/${VERSION}${ISOFILE}, $(cat ${ISOFILE}.md5)" >/bolt
