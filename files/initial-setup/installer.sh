#! /bin/bash

# sanity check that all variables were set
if [ -z ${ISE_ROOT+x} ]
then
    echo "Installer script called without all environment variables set!"
    exit 1
fi

EFI_GUID='c12a7328-f81f-11d2-ba4b-00a0c93ec93b'
[[ -d /sys/firmware/efi ]] && IS_EFI=1

if [[ -z "${ISE_EFI}" ]] && [[ -n "$IS_EFI" ]] ; then
    echo "Unknown EFI partition"
    exit 1
fi

if [[ -n "$IS_EFI" ]] ; then
    echo ":: Setting 'EFI' Label to ${ISE_EFI}"
    # Make sure EFI parititon
    sudo fatlabel ${ISE_EFI} EFI || {
        echo "Failed to change EFI partition label"
        exit 1
    }
fi

SYSROOT="/.installer-root"
SYSIMAGE='/run/iso/sysroot.img'

getval() {
    unsquashfs -cat $SYSIMAGE share/factory/etc/os-release | grep "^$1=" | cut -d '=' -f2
}

ID=$(getval "ID")
VERSION=$(getval "VERSION")
KERVER=$(uname -r)

echo ":: System Version: ${VERSION}"
echo ":: Kernel Version: ${KERVER}"

if [[ -z $ID ]] || [[ -z $VERSION ]] ; then
    echo "Invalid system image, missing required values"
    exit 1
fi

sudo mkdir -p ${SYSROOT}

echo ":: Formatting ${ISE_ROOT}"
sudo mkfs.ext4 -F ${ISE_ROOT} >/dev/null || {
    echo "Failed to mkfs.ext4 ${ISE_ROOT}"
    exit 1
}

echo ":: Mounting ${ISE_ROOT} on ${SYSROOT}"
sudo mount ${ISE_ROOT} ${SYSROOT} || {
    echo "Failed to mount ${ISE_ROOT}"
    exit 1
}

echo ":: Creating System Hierarchy"
sudo mkdir -p ${SYSROOT}/{boot/swupd/${VERSION},sysroot/images} || {
    echo "failed to create required sysroot path '${SYSROOT}'"
    exit 1
}

echo ":: Installing system image $VERSION"
sudo cp $SYSIMAGE ${SYSROOT}/sysroot/images/$VERSION || {
    echo "failed to install '${SYSROOT}'"
    exit 1
}

if [[ -n "$IS_EFI" ]] ; then
    sudo mkdir -p ${SYSROOT}/efi
    sudo mount ${ISE_EFI} ${SYSROOT}/efi || {
        sudo umount ${ISE_ROOT}

        echo "Failed to mount ${ISE_EFI} ${SYSROOT}/efi"
        exit 1
    }
fi

cleanup() {
    [[ -n "$IS_EFI" ]] && sudo umount ${SYSROOT}/efi/
    sudo umount ${SYSROOT}
}

trap cleanup EXIT

echo ":: Installing kernel ${KERVER}"

sudo cp -r /lib/modules/$KERVER/{bzImage,initramfs} ${SYSROOT}/boot/swupd/${VERSION}/ || {
    echo "failed to installer kernel"
    exit 1
}

echo "rd.image=/sysroot/images/$VERSION quiet splash loglevel=3 systemd.show_status=auto udev.log_level=3" >${SYSROOT}/boot/swupd/${VERSION}/config

ROOT_UUID=$(sudo lsblk -no uuid ${ISE_ROOT})

echo ":: Installing Bootloader"
if [[ -n "${IS_EFI}" ]] ; then
    sudo grub-install --boot-directory=${SYSROOT}/boot --efi-directory=${SYSROOT}/efi --root-directory=${SYSROOT} --target=x86_64-efi
else
    disk="/dev/$(basename $(readlink -f /sys/class/block/$(basename ${ISE_ROOT})/..))"
    sudo grub-install --boot-directory=${SYSROOT}/boot --root-directory=${SYSROOT} --target=i386-pc ${disk}
fi

KERVER=$(uname -r)

echo ":: Configuring Bootloader"
sudo install -vDm644 /dev/stdin ${SYSROOT}/boot/grub/grub.cfg << EOF
set timeout=10
set default="RLXOS Initial Setup"

menuentry "RLXOS Initial Setup" {
    insmod all_video

    linux /boot/swupd/${VERSION}/bzImage root=UUID=$ROOT_UUID rd.image=/sysroot/images/$VERSION quiet splash loglevel=3 systemd.show_status=auto udev.log_level=3
    initrd /boot/swupd/${VERSION}/initramfs.img
}

EOF

# Sleep for 2 seconds
sleep 2

exit 0