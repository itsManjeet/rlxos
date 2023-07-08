#!/bin/bash



PKG_CONFIG_FLDR="pkg-config-$PKG_CONFIG_VERSION"

RLXOS_DOWNLOAD "https://pkg-config.freedesktop.org/releases/$PKG_CONFIG_FLDR.tar.gz"

RLXOS_EXTRACT $PKG_CONFIG_FLDR.tar.gz

cd $RLXOS_BUILD_DIR/$PKG_CONFIG_FLDR


./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-host-tool        \
            --docdir=/usr/doc/pkg-config

make
make install