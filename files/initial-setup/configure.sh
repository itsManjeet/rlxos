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

if [ "${OSI_DEVICE_IS_PARTITION}" -ne "1" ] ; then

    if [ -n $IS_EFI ] ; then
        sudo parted --script ${OSI_DEVICE_PATH}  \
        mklabel gpt                     \
        mkpart primary 1MiB 500MiB      \
        set 1 esp on                    \
        mkpart primary 500MiB 100% || {
            echo "Failed to partition ${OSI_DEVICE_PATH}"
            exit 1
        }
        OSI_DEVICE_EFI_PARTITION=$(lsblk ${OSI_DEVICE_PATH} -no path | sed '2!d')

        echo "EFI PARTITION: ${OSI_DEVICE_EFI_PARTITION}"
        sudo mkfs.fat -n EFI -F32 ${OSI_DEVICE_EFI_PARTITION} || {
            echo "Failed to format ${OSI_DEVICE_PATH}"
            exit 1
        }

        OSI_DEVICE_PATH=$(lsblk ${OSI_DEVICE_PATH} -no path | sed '3!d')
    echo "DEVICE PATH: ${OSI_DEVICE_PATH}"
    else
        sudo parted --script ${OSI_DEVICE_PATH}  \
        mklabel msdos                   \
        mkpart primary 1MiB 100%   || {
            echo "Failed to partition ${OSI_DEVICE_PATH}"
            exit 1
        }
        OSI_DEVICE_PATH=$(lsblk ${OSI_DEVICE_PATH} -no path | sed '2!d')
    echo "DEVICE PATH: ${OSI_DEVICE_PATH}"
    fi

else
    if [ -n $IS_EFI ] || [ -z "${OSI_DEVICE_EFI_PARTITION}" ] ; then
        echo "Detecting EFI partition"
        OSI_DEVICE_EFI_PARTITION=$(sudo lsblk -no parttype,path | grep -iF "${EFI_GUID}" | awk '{print $2}' | head -n1)
    fi
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
SYSIMAGE='/run/iso/sysroot.img'

getval() {
    unsquashfs -cat $SYSIMAGE share/factory/etc/os-release | grep "$1" | cut -d '=' -f2
}

ID=$(getval "ID")
VERSION=$(getval "VERSION")
KERVER=$(uname -r)

if [[ -z $ID ]] || [[ -z $VERSION ]] ; then
    echo "Invalid system image, missing required values"
    exit 1
fi 

sudo mkdir -p ${SYSROOT}/sysroot/{boot/modules/,images} || {
    echo "failed to create required sysroot path '${SYSROOT}'"
    exit 1
}

echo "Installing system image $VERSION"
sudo cp $sysimage ${SYSROOT}/sysroot/images/$VERSION || {
    echo "failed to install '${SYSROOT}'"
    exit 1
}

echo "MOUNTING ${OSI_DEVICE_ROOT_PATH} ${SYSROOT}"
sudo mount ${OSI_DEVICE_ROOT_PATH} ${SYSROOT} || {
    echo "Failed to mount ${OSI_DEVICE_ROOT_PATH}"
    exit 1
}


suod ln -sv sysroot/boot ${SYSROOT}/boot || {
    echo "failed to create required symlink"
    exit 1
}

if [[ -n "$IS_EFI" ]] ; then
    sudo mkdir -p ${SYSROOT}/sysroot/efi
    sudo mount ${OSI_DEVICE_EFI_PARTITION} ${SYSROOT}/sysroot/efi || {
        sudo umount ${OSI_DEVICE_PATH}

        echo "Failed to mount ${OSI_DEVICE_EFI_PARTITION} ${SYSROOT}/sysroot/efi"
        exit 1
    }
fi

cleanup() {
    [[ -n "$IS_EFI" ]] && sudo umount ${SYSROOT}/sysroot/efi/
    sudo umount ${SYSROOT}
}

trap cleanup EXIT

sudo cp -r /boot/modules/$KERVER ${SYSROOT}/sysroot/boot/modules/ || {
    echo "failed to installer kernel"
    exit 1
}

ROOT_UUID=$(sudo lsblk -no uuid ${OSI_DEVICE_ROOT_PATH})

if [[ -n "${IS_EFI}" ]] ; then
    sudo grub-install --boot-directory=${SYSROOT}/boot --efi-directory=${SYSROOT}/boot --root-directory=${SYSROOT} --target=x86_64-efi
else
    disk="/dev/$(basename $(readlink /sys/class/block/$(basename ${OSI_DEVICE_ROOT_PATH})))"
    sudo grub-install --boot-directory=${SYSROOT}/boot --root-directory=${SYSROOT} --target=i386-pc ${disk}
fi

KERVER=$(uname -r)

cat >${SYSROOT}/boot/grub/grub.cfg << EOF
set timeout=10
set default="RLXOS Initial Setup"

menuentry "RLXOS Initial Setup" {
    insmod all_video

    linux /sysroot/boot/modules/$KERVER/bzImage root=UUID=$ROOT_UUID rd.image=/sysroot/images/$VERSION
    initrd /sysroot/boot/modules/$KERVER/initramfs.img
}

EOF

exit 0