#!/bin/sh

if [[ "$EUID" -ne 0 ]] ; then 
    echo "Error! need superuser access"
    exit
fi

RLX_SYS_DIR=${RLX_SYS_DIR:-'/run/initramfs'}

mountpoint /boot || {
    WE_MOUNT=1
    mount ${RLX_SYS_DIR}/boot /boot --bind
    if [[ $? != 0 ]] ; then
        echo "Error! Failed to mount boot directory"
        exit 1
    fi
}

    GRUB_DEVICE=$(mount | grep " /run/initramfs " | awk '{print $1}')    \
    GRUB_DEVICE_BOOT=${GRUB_DEVICE}                                      \
grub-mkconfig -o /run/initramfs/boot/grub/grub.cfg

if [[ ! -z ${WE_MOUNT} ]] ; then
    umount /boot
fi
