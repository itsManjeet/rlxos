#!/bin/sh

for bin in go rsync wget mksquashfs flex bison bc qemu-system-x86_64; do
    if ! which $bin >/dev/null ; then
        echo "ERROR: $bin not found"
    fi
done

for header in gelf.h openssl/ssl.h; do
    if [ ! -e /usr/include/$header ] ; then
        echo "ERROR: /usr/include/$header not found"
    fi
done