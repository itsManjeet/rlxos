#!/bin/sh

export PATH=$PATH:/usr/sbin:/sbin

for bin in go rsync wget mksquashfs flex bison bc \
    cpio make g++ unzip bzip2 mkdosfs mmd xorriso; do
    if ! which $bin >/dev/null ; then
        echo "ERROR: $bin not found"
    fi
done

for header in gelf.h openssl/ssl.h; do
    if [ ! -e /usr/include/$header ] ; then
        echo "ERROR: /usr/include/$header not found"
    fi
done