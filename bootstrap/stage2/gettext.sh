#!/bin/bash



GETTEXT_SRC_FLDR="gettext-$GETTEXT_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/gettext/$GETTEXT_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $GETTEXT_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$GETTEXT_SRC_FLDR


./configure --disable-shared

make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin