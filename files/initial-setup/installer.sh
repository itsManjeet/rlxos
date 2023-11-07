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
sudo mkdir -p ${SYSROOT}/boot || {
    sudo umount ${SYSROOT}
    echo "failed to create required sysroot path '${SYSROOT}'"
    exit 1
}

if [[ -n "$IS_EFI" ]] ; then
    sudo mount ${ISE_EFI} ${SYSROOT}/boot || {
        sudo umount ${ISE_ROOT}
        echo "Failed to mount ${ISE_EFI} ${SYSROOT}/boot"
        exit 1
    }
fi

cleanup() {
    [[ -n "$IS_EFI" ]] && sudo umount ${SYSROOT}/efi/
    sudo umount ${SYSROOT}
}

trap cleanup EXIT


sudo mkdir -p ${SYSROOT}/ostree/repo || {
    echo "failed to create repo dir"
    exit 1
}

echo ":: Creating OStree Repository"
sudo ostree init --repo=${SYSROOT}/ostree/repo --mode=bare || {
    echo "failed to install '${SYSROOT}'"
    exit 1
}

echo ":: Cloning OStree into the device (this might take a while)"
sudo ostree --repo=${SYSROOT}/ostree/repo pull-local "/ostree/repo" @@OSTREE_BRANCH@@ || {
    echo "failed to clone OStree repository"
    exit 1
}

echo ":: Creating OStree filesystem"
sudo ostree admin init-fs ${SYSROOT} || {
    echo "failed to creating ostree filesystem"
    exit 1
}

echo ":: Initializing OStree filesystem"
sudo ostree admin os-init --sysroot=${SYSROOT} rlxos || {
    echo "failed to initialize os roots"
    exit 1
}

ROOT_UUID=$(sudo lsblk -no uuid ${ISE_ROOT})

echo ":: Deploying OStree"
sudo ostree admin deploy --os="rlxos"   \
    --sysroot="${SYSROOT}" @@OSTREE_BRANCH@@ \
    --karg="rw" --karg="quiet" --karg="splash" \
    --karg="root=UUID=$ROOT_UUID" || {
    echo "failed to deploy OStree"
    exit 1
}

echo ":: Setting up origin"
sudo ostree admin set-origin --sysroot="${SYSROOT}" \
    --index=0 rlxos https://ostree.rlxos.dev/ @@OSTREE_BRANCH@@ || {
    echo "failed to setup origin"
    exit 1
}

sudo ostree remote delete rlxos --repo=${SYSROOT}/ostree/repo

echo ":: Installing boot files"
sudo cp -fr "${SYSROOT}"/ostree/boot.1/rlxos/*/*/boot/EFI/ "${SYSROOT}"/boot/ || {
    echo "failed to install boot files"
    exit 1
}

echo ":: Installing Bootloader"
if [[ -n "${IS_EFI}" ]] ; then
    sudo bootctl --esp-path=${SYSROOT}/boot --boot-path=${SYSROOT}/boot install
else
    disk="/dev/$(basename $(readlink -f /sys/class/block/$(basename ${ISE_ROOT})/..))"
    sudo grub-install --boot-directory=${SYSROOT}/boot --root-directory=${SYSROOT} --target=i386-pc ${disk}
fi

# Sleep for 2 seconds
sleep 2

exit 0