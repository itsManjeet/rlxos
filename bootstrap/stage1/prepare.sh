#!/bin/bash

set -e

[[ "$UID" -eq 0 ]] || {
    INFO_MESG "Need superuser permission to prepare environment"
    exec sudo "$0" "$@"
    exit 0
}

[[ $(getent group $RLXOS_USR) ]] || {
    INFO_MESG "Adding $RLXOS_USR group"
    groupadd $RLXOS_USR
}

[[ $(getent passwd $RLXOS_USR) ]] || {
    INFO_MESG "Adding $RLXOS_USR user"
    useradd -s /bin/bash -g $RLXOS_USR -m -k /dev/null rlxos
}



install -vd -o ${RLXOS_USR} -g ${RLXOS_USR} ${RLX}/usr
install -vd -o $RLXOS_USR -g $RLXOS_USR $RLXOS/{etc,usr/{bin,lib},var}
ln -sv usr/lib $RLXOS/lib
ln -sv usr/bin $RLXOS/bin
ln -sv usr/bin $RLXOS/sbin
ln -sv bin $RLXOS/sbin

case $RLXOS_ARCH in
    x86_64)
        ln -sv usr/lib $RLXOS/lib64
        ln -sv lib $RLXOS/usr/lib64
        ;;
esac

install -vd -o $RLXOS_USR -g $RLXOS_USR $RLXOS/tools $RLXOS_SRC_DIR $RLXOS_BUILD_DIR $RLXOS_CACHE_DIR

chown $RLXOS_USR $RLXOS

cat > /home/$RLXOS_USR/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > /home/$RLXOS_USR/.bashrc << "EOF"
set +h
umask 022
RLXOS=$RLXOS
RLXOS_SRC_DIR=$RLXOS_SRC_DIR
RLXOS_BUILD_DIR=$RLXOS_BUILD_DIR
RLXOS_TGT=$RLXOS_TGT
RLXOS_HOST=$RLXOS_HOST
LC_ALL=POSIX
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$RLXOS/tools/bin:$PATH
export RLXOS RLXOS_SRC_DIR RLXOS_BUILD_DIR RLXOS_TGT RLXOS_HOST LC_ALL PATH
EOF
