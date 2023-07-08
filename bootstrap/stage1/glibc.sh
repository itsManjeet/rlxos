#!/bin/bash

set -e

. .config.sh
. ver.sh

GLIBC_SRC_FLDR="glibc-$GLIBC_VERSION"
RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/glibc/$GLIBC_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $GLIBC_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$GLIBC_SRC_FLDR

patch -Np1 -i $RLXOS_PATCHES/glibc/glibc-2.34-fhs-1.patch

mkdir -pv build && cd build

echo "rootsbindir=/usr/bin" >configparam
../configure \
    --prefix=/usr \
    --libexecdir=/usr/lib \
    --host=$RLXOS_TGT \
    --build=$(../scripts/config.guess) \
    --enable-kernel=3.2 \
    --with-headers=$RLXOS/usr/include \
    libc_cv_slibdir=/usr/lib \
    --with-bugurl=https://rlxos.dev/bugs

make
make DESTDIR=$RLX install

# Test

echo 'int main(){}' >dummy.c
$RLXOS_TGT-gcc dummy.c
out=$(readelf -l a.out | grep '/ld-linux')

if [[ "$out" != "      [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]" ]]; then
    ERR_MESG "glibc build is targeting $out"
    read a
fi

INFO_MESG "installing limit.h"
$RLXOS/tools/libexec/gcc/$RLXOS_TGT/${GCC_VERSION}/install-tools/mkheaders
