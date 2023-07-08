#!/bin/bash



UTILLINUX_SRC_FLDR="util-linux-$UTILLINUX_VERSION"

RLXOS_DOWNLOAD "https://www.kernel.org/pub/linux/utils/util-linux/v${UTILLINUX_VERSION}/$UTILLINUX_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $UTILLINUX_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$UTILLINUX_SRC_FLDR

mkdir -pv /var/lib/hwclock
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --docdir=/usr/doc/util-linux \
    --sbindir=/usr/bin \
    --bindir=/usr/bin \
    --libdir=/usr/lib \
    --disable-chfn-chsh \
    --disable-login \
    --disable-nologin \
    --disable-su \
    --disable-setpriv \
    --disable-runuser \
    --disable-pylibmount \
    --disable-static \
    --without-python
make
make install
