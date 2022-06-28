#!/bin/sh

if [[ "$EUID" -ne 0 ]] ; then 
    echo "Error! need superuser access"
    exit
fi

GRUB_DEVICE=$(mount | grep " /run/initramfs " | awk '{print $1}')    \
GRUB_DEVICE_BOOT=${GRUB_DEVICE}                                      \
grub-mkconfig -o /run/initramfs/boot/grub/grub.cfg
