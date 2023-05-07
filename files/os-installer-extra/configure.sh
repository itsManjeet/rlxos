#! /bin/sh

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

echo 'Mounting Installer ISO'
sudo mkdir -p /run/mount/installercd || {
    echo "Failed to create installer directory"
    exit 1
}
sudo mount -t iso9660 /dev/disk/by-label/@@VOLUME_ID@@ /run/mount/installercd || {
    echo "Failed to mount /dev/disk/by-label/@@VOLUME_ID@@"
    exit 1
}

echo 'Mounting System Image'
sudo mkdir -p /run/mount/squash || {
    echo 'Failed to create squash directory'
    exit 1
}

sudo mount -t squashfs /run/mount/installercd/rlxos.sfs \
    /run/mount/squash || {
        echo 'Failed to mount system image'
        exit 1
    }


if [ "${OSI_DEVICE_IS_PARTITION}" -ne "1" ] ; then
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
    if [ -z "${OSI_DEVICE_EFI_PARTITION}" ] ; then
        echo "Detecting EFI partition"
        OSI_DEVICE_EFI_PARTITION=$(sudo lsblk -no parttype,path | grep -iF "${EFI_GUID}" | awk '{print $2}' | head -n1)
    fi
fi

if [ -z "${OSI_DEVICE_EFI_PARTITION}" ] ; then
    echo "Unknown EFI partition"
    exit 1
fi

OSTREE_BRANCH="@@OSTREE_BRANCH@@"
SYSROOT="/sysroot"
OSTREE_REPO="${SYSROOT}/ostree/repo"

# Make sure EFI parititon
sudo fatlabel ${OSI_DEVICE_EFI_PARTITION} EFI || {
    echo "Failed to change EFI partition label"
    exit 1
}

sudo mkdir -p ${SYSROOT} || {
    echo "failed to create required sysroot path '${SYSROOT}'"
    exit 1
}

echo "FORMATTING ${OSI_DEVICE_PATH}"
sudo mkfs.btrfs -f ${OSI_DEVICE_PATH} || {
    echo "Failed to format ${OSI_DEVICE_PATH}"
    exit 1
}

echo "MOUNTING ${OSI_DEVICE_PATH} ${SYSROOT}"
sudo mount ${OSI_DEVICE_PATH} ${SYSROOT} || {
    echo "Failed to mount ${OSI_DEVICE_PATH}"
    exit 1
}


sudo mkdir -p ${SYSROOT}/boot || {
    sudo umount ${OSI_DEVICE_PATH}

    echo "Failed to create boot partition ${SYSROOT}/boot"
    exit 1
}

sudo mount ${OSI_DEVICE_EFI_PARTITION} ${SYSROOT}/boot/ || {
    sudo umount ${OSI_DEVICE_PATH}

    echo "Failed to mount ${OSI_DEVICE_EFI_PARTITION} ${SYSROOT}/boot"
    exit 1
}

cleanup() {
    sudo umount ${SYSROOT}/boot
    sudo umount ${SYSROOT}
}

trap cleanup EXIT

sudo mkdir -p ${OSTREE_REPO} || {
    echo "Failed to create ${OSTREE_REPO}"
    exit 1
}

sudo ostree init --repo=${OSTREE_REPO} --mode=bare || {
    echo "Failed to initialize repository"
    exit 1
}

sudo ostree --repo=${OSTREE_REPO} pull-local "/run/mount/squash/ostree/repo" ${OSTREE_BRANCH} || {
    echo "Failed to pull from local repository"
    exit 1
}

sudo ostree admin init-fs ${SYSROOT} || {
    echo "Failed to initialize filesystem"
    exit 1
}

sudo ostree admin os-init --sysroot=${SYSROOT} rlxos || {
    echo "Failed to initiailze os roots"
    exit 1
}

UUID=$(sudo lsblk -no uuid ${OSI_DEVICE_PATH})

sudo ostree admin deploy --os="rlxos" \
    --sysroot=${SYSROOT} ${OSTREE_BRANCH} \
    --karg="rw" --karg="quiet" --karg="splash" \
    --karg="console=tty0" --karg="root=UUID=$UUID" || {
        echo "OS deployment failed"
        exit 1
    }

sudo ostree admin set-origin --sysroot="${SYSROOT}" \
    --index=0 \
    rlxos "https://ostree.rlxos.dev/" ${OSTREE_BRANCH}

sudo ostree remote delete rlxos --repo=${OSTREE_REPO}
sudo cp -fr "${SYSROOT}"/ostree/boot.1/rlxos/*/*/boot/EFI/ "${SYSROOT}/boot/" || {
    echo "Failed to copy boot files"
    exit 1
}

YES=$(sudo bootctl --esp-path=${SYSROOT}/boot --boot-path=${SYSROOT}/boot is-installed)
if [[ "${YES}" != "yes" ]] ; then
    sudo bootctl --esp-path=${SYSROOT}/boot --boot-path=${SYSROOT}/boot installed
else
    sudo bootctl --esp-path=${SYSROOT}/boot --boot-path=${SYSROOT}/boot update
fi

exit 0
