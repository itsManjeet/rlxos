#!/bin/bash

ISO=$1
shift

[[ -z $ISO ]] && {
    echo "ERROR: no iso file specified"
    exit 1
}
qemu-system-x86_64 -cdrom $ISO  \
    -m 2G -smp 2                \
    -nographic $@