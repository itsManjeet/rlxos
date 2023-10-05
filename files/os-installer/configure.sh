#! /bin/bash

# This is an example configuration script. For OS-Installer to use it, place it at:
# /etc/os-installer/scripts/configure.sh
# The script gets called with the environment variables from the install script
# (see install.sh) and these additional variables:
# OSI_USER_NAME          : User's name. Not ASCII-fied
# OSI_USER_AUTOLOGIN     : Whether to autologin the user
# OSI_USER_PASSWORD      : User's password. Can be empty if autologin is set.
# OSI_FORMATS            : Locale of formats to be used
# OSI_TIMEZONE           : Timezone to be used
# OSI_ADDITIONAL_SOFTWARE: Space-separated list of additional packages to install

# sanity check that all variables were set
if [ -z ${OSI_LOCALE+x} ] || \
   [ -z ${OSI_DEVICE_PATH+x} ] || \
   [ -z ${OSI_DEVICE_IS_PARTITION+x} ] || \
   [ -z ${OSI_DEVICE_EFI_PARTITION+x} ] || \
   [ -z ${OSI_USE_ENCRYPTION+x} ] || \
   [ -z ${OSI_ENCRYPTION_PIN+x} ] || \
   [ -z ${OSI_USER_NAME+x} ] || \
   [ -z ${OSI_USER_AUTOLOGIN+x} ] || \
   [ -z ${OSI_USER_PASSWORD+x} ] || \
   [ -z ${OSI_FORMATS+x} ] || \
   [ -z ${OSI_TIMEZONE+x} ] || \
   [ -z ${OSI_ADDITIONAL_SOFTWARE+x} ]
then
    echo "Installer script called without all environment variables set!"
    exit 1
fi

echo 'Configuration started.'
echo ''
echo 'Variables set to:'
echo 'OSI_LOCALE               ' $OSI_LOCALE
echo 'OSI_DEVICE_PATH          ' $OSI_DEVICE_PATH
echo 'OSI_DEVICE_IS_PARTITION  ' $OSI_DEVICE_IS_PARTITION
echo 'OSI_DEVICE_EFI_PARTITION ' $OSI_DEVICE_EFI_PARTITION
echo 'OSI_USE_ENCRYPTION       ' $OSI_USE_ENCRYPTION
echo 'OSI_ENCRYPTION_PIN       ' $OSI_ENCRYPTION_PIN
echo 'OSI_USER_NAME            ' $OSI_USER_NAME
echo 'OSI_USER_AUTOLOGIN       ' $OSI_USER_AUTOLOGIN
echo 'OSI_USER_PASSWORD        ' $OSI_USER_PASSWORD
echo 'OSI_FORMATS              ' $OSI_FORMATS
echo 'OSI_TIMEZONE             ' $OSI_TIMEZONE
echo 'OSI_ADDITIONAL_SOFTWARE  ' $OSI_ADDITIONAL_SOFTWARE
echo ''

EFI_GUID='c12a7328-f81f-11d2-ba4b-00a0c93ec93b'
[[ -d /sys/firmware/efi ]] && IS_EFI=1

mkdir -p /tmp/definitions/

if [[ -n "$IS_EFI" ]] ; then
cat >/tmp/definitions/10-efi.conf << "EOF"
[Partition]
Type=esp
Format=vfat
CopyFiles=/boot
SizeMinBytes=100M
SizeMaxBytes=512M
EOF

fi

cat >/tmp/definitions/20-usr-A.conf << "EOF"
[Partition]
Type=usr
Label=rlxos_usr_0
SizeMinBytes=4G
SizeMaxBytes=5G
EOF

cat >/tmp/definitions/20-usr-B.conf << "EOF"
[Partition]
Type=usr
Label=rlxos_usr_0
SizeMinBytes=4G
SizeMaxBytes=5G
EOF

cat >/tmp/definitions/30-root.conf << "EOF"
[Partition]
Type=root
Label=root
Format=ext4
FactoryReset=yes
GrowFileSystem=yes
EOF


if [ "${OSI_DEVICE_IS_PARTITION}" -ne "1" ] ; then

    echo "PARTITIONING DRIVE"
    systemd-repart --definitions=/tmp/definitions ${OSI_DEVICE_PATH} --dry-run=no || {
        echo "PARTITIONING DRIVE FAILED"
        exit 1
    }

    OSI_DEVICE_ROOT_PATH=$(lsblk ${OSI_DEVICE_PATH} -no path,label | grep 'root' | awk '{print $1}')
    OSI_DEVICE_USR_PATH=$(lsblk ${OSI_DEVICE_PATH} -no path,label | grep 'rlxos_usr_0' | head -n1 | awk '{print $1}')

    echo "DEVICE ROOT PATH: ${OSI_DEVICE_ROOT_PATH}"
    echo "DEVICE USR PATH: ${OSI_DEVICE_USR_PATH}"

    if [[ -z "${OSI_DEVICE_EFI_PARTITION}" ]] && [[ -n "$IS_EFI" ]] ; then
        echo "Detecting EFI partition"
        OSI_DEVICE_EFI_PARTITION=$(lsblk ${OSI_DEVICE_PATH} -no parttype,path | grep -iF "${EFI_GUID}" | awk '{print $2}' | head -n1)
    fi

else
    echo "PARITION MODE IS NOT YET SUPPORTED"
    exit 1
fi

if [[ -z "${OSI_DEVICE_EFI_PARTITION}" ]] && [[ -n "$IS_EFI" ]] ; then
    echo "Unknown EFI partition"
    exit 1
fi

if [[ -n "$IS_EFI" ]] ; then
    # Make sure EFI parititon
    sudo fatlabel ${OSI_DEVICE_EFI_PARTITION} EFI || {
        echo "Failed to change EFI partition label"
        exit 1
    }
fi

SYSROOT="/.installer-root"

sudo mkdir -p ${SYSROOT}/sysroot/{boot,images} || {
    echo "failed to create required sysroot path '${SYSROOT}'"
    exit 1
}

echo "REFORMATTING ${OSI_DEVICE_PATH}"
sudo dd if=/run/iso/sysroot.img of=${OSI_DEVICE_USR_PATH} bs=1M status=progress || {
    echo "Failed to reformat ${OSI_DEVICE_USR_PATH}"
    exit 1
}

echo "MOUNTING ${OSI_DEVICE_ROOT_PATH} ${SYSROOT}"
sudo mount ${OSI_DEVICE_ROOT_PATH} ${SYSROOT} || {
    echo "Failed to mount ${OSI_DEVICE_ROOT_PATH}"
    exit 1
}


sudo mkdir -p ${SYSROOT}/boot || {
    sudo umount ${OSI_DEVICE_PATH}

    echo "Failed to create boot partition ${SYSROOT}/boot"
    exit 1
}

if [[ -n "$IS_EFI" ]] ; then
    sudo mount ${OSI_DEVICE_EFI_PARTITION} ${SYSROOT}/boot/ || {
        sudo umount ${OSI_DEVICE_PATH}

        echo "Failed to mount ${OSI_DEVICE_EFI_PARTITION} ${SYSROOT}/boot"
        exit 1
    }
fi

cleanup() {
    [[ -n "$IS_EFI" ]] && sudo umount ${SYSROOT}/boot
    sudo umount ${SYSROOT}
}

trap cleanup EXIT

sudo cp -r /boot/modules ${SYSROOT}/boot/ || {
    echo "failed to installer kernel"
    exit 1
}

ROOT_UUID=$(sudo lsblk -no uuid ${OSI_DEVICE_ROOT_PATH})
USR_UUID=$(sudo lsblk -no uuid ${OSI_DEVICE_USR_PATH})

if [[ -n "${IS_EFI}" ]] ; then
    sudo grub-install --boot-directory=${SYSROOT}/boot --efi-directory=${SYSROOT}/boot --root-directory=${SYSROOT} --target=x86_64-efi
else
    disk=$(readlink /sys/class/block/$(basename ${OSI_DEVICE_ROOT_PATH}))
    disk=${disk%/*}
    disk=/dev/${disk##*/}

    sudo grub-install --boot-directory=${SYSROOT}/boot --root-directory=${SYSROOT} --target=i386-pc ${disk}
fi

KERVER=$(uname -r)

cat >${SYSROOT}/boot/grub/grub.cfg << EOF
set timeout=10
set default="RLXOS Initial Setup"

menuentry "RLXOS Initial Setup" {
    insmod all_video

    linux /boot/modules/$KERVER/bzImage root=UUID=$ROOT_UUID rd.image=${OSI_DEVICE_USR_PATH}
    initrd /boot/initramfs.img
}

EOF

exit 0