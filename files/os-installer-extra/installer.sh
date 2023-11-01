#!/bin/sh

if [ -z ${ISE_ROOT+x} ]
then
    echo "Installer script called without all environment variables set!"
    exit 1
fi

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

[[ -d /sys/firmware/efi ]] && IS_EFI=1

if [[ -z "${ISE_EFI}" ]] && [[ -n "$IS_EFI" ]] ; then
    echo "Unknown EFI partition"
    exit 1
fi

if [ -z "${ISE_EFI}" ] ; then
    echo "Unknown EFI partition"
    exit 1
fi

OSTREE_BRANCH="@@OSTREE_BRANCH@@"
SYSROOT="/sysroot"
OSTREE_REPO="${SYSROOT}/ostree/repo"

# Make sure EFI parititon
sudo fatlabel ${ISE_EFI} EFI || {
    echo "Failed to change EFI partition label"
    exit 1
}

sudo mkdir -p ${SYSROOT} || {
    echo "failed to create required sysroot path '${SYSROOT}'"
    exit 1
}

echo "FORMATTING ${ISE_ROOT}"
sudo mkfs.btrfs -f ${ISE_ROOT} || {
    echo "Failed to format ${ISE_ROOT}"
    exit 1
}

echo "MOUNTING ${ISE_ROOT} ${SYSROOT}"
sudo mount ${ISE_ROOT} ${SYSROOT} || {
    echo "Failed to mount ${ISE_ROOT}"
    exit 1
}


sudo mkdir -p ${SYSROOT}/boot || {
    sudo umount ${ISE_ROOT}

    echo "Failed to create boot partition ${SYSROOT}/boot"
    exit 1
}

sudo mount ${ISE_EFI} ${SYSROOT}/boot/ || {
    sudo umount ${ISE_ROOT}

    echo "Failed to mount ${ISE_EFI} ${SYSROOT}/boot"
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

UUID=$(sudo lsblk -no uuid ${ISE_ROOT})

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
