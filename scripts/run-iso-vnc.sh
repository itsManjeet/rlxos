#!/bin/sh

echo "starting server at :5900"
qemu-system-x86_64 \
    -cdrom ${1} \
    -vnc :0 \
    -smp 2 \
    -m 2048 \
    -drive file=qemu.qcow2,if=virtio