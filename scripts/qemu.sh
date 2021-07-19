#!/bin/sh

qemu-system-x86_64 -cdrom ${1} -m 1024 -enable-kvm -cpu host