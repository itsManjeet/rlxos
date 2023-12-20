#! /bin/bash

# sanity check that all variables were set
if [ -z ${ISE_ROOT+x} ]
then
    echo "Installer script called without all environment variables set!"
    sleep 999

    exit 1
fi

EFI_GUID='c12a7328-f81f-11d2-ba4b-00a0c93ec93b'
[[ -d /sys/firmware/efi ]] && IS_EFI=1

if [[ -z "${ISE_EFI}" ]] && [[ -n "$IS_EFI" ]] ; then
    echo "Unknown EFI partition"
    sleep 999
    
    exit 1
fi

if [[ -n "$IS_EFI" ]] ; then
    echo ":: Setting 'EFI' Label to ${ISE_EFI}"
    # Make sure EFI parititon
    sudo fatlabel ${ISE_EFI} EFI || {
        echo "Failed to change EFI partition label"
        sleep 999

        exit 1
    }
fi

SYSROOT="/.installer-root"

sudo mkdir -p ${SYSROOT}

echo ":: Formatting ${ISE_ROOT}"
sudo mkfs.ext4 -F ${ISE_ROOT} >/dev/null || {
    echo "Failed to mkfs.ext4 ${ISE_ROOT}"
    sleep 999

    exit 1
}

echo ":: Mounting ${ISE_ROOT} on ${SYSROOT}"
sudo mount ${ISE_ROOT} ${SYSROOT} || {
    echo "Failed to mount ${ISE_ROOT}"
    sleep 999

    exit 1
}

echo ":: Creating System Hierarchy"
sudo mkdir -p ${SYSROOT}/boot || {
    sudo umount ${SYSROOT}
    echo "failed to create required sysroot path '${SYSROOT}/boot'"
    sleep 999

    exit 1
}

if [[ -n "$IS_EFI" ]] ; then
    sudo mkdir -p ${SYSROOT}/efi || {
        echo "failed to create efi directory"
        sleep 999

        exit 1
    }
    sudo mount ${ISE_EFI} ${SYSROOT}/efi || {
        sudo umount ${ISE_ROOT}
        echo "Failed to mount ${ISE_EFI} ${SYSROOT}/efi"
        sleep 999

        exit 1
    }
fi

cleanup() {
    [[ -n "$IS_EFI" ]] && sudo umount ${SYSROOT}/efi/
    sudo umount ${SYSROOT}
}

trap cleanup EXIT


echo ":: Installing System Image"
sudo unsquashfs -f -d ${SYSROOT} /run/initramfs/live/LiveOS/squashfs.img || {
    echo "failed to install system image"
    sleep 999

    exit 1
}

KERNEL_VERSION=$(ls -1 ${SYSROOT}/lib/modules/ | head -n1)

sudo chroot ${SYSROOT} /bin/bash -e << EOT
echo ":: Creating file hierarchy"
mkdir -p /dev /sys /proc

mount -t devtmpfs none /dev
mount -t sysfs    none /sys
mount -t proc     none /proc

if [[ -n ${IS_EFI} ]] ; then
    mount -t efivarfs none /sys/firmware/efi/efivars
fi

echo ":: Generating initramfs"
dracut /boot/initramfs-${KERNEL_VERSION}.img

echo ":: Installing kernel"
cp /lib/modules/${KERNEL_VERSION}/bzImage /boot/vmlinuz-${KERNEL_VERSION}

echo ":: Installing Bootloader"
if [[ -n "${IS_EFI}" ]] ; then
    grub-install --boot-directory=/boot --efi-directory=/efi --target=x86_64-efi
else
    disk="/dev/$(basename $(readlink -f /sys/class/block/$(basename ${ISE_ROOT})/..))"
    grub-install --boot-directory=/boot --target=i386-pc ${disk}
fi

echo ":: Generating bootloader configuration"
update-grub
EOT || {
    echo "Failed to configure system"
    sleep 999

    exit 1
}


# Sleep for 2 seconds
sleep 5

exit 0