#!/bin/bash

set -e

. .config.sh

[[ "$UID" -eq 0 ]] || {
    INFO_MESG "Need superuser permission to prepare environment"
    exec sudo "$0" "$@"
    exit 0
}

INFO_MESG "Executing As '$(whoami)'"

_PDIR=$(pwd)

[[ -f $RLXOS/tools/ownership ]] || {
    chown -Rv root:root $RLXOS/{usr,var,etc,tools}
    case $RLXOS_ARCH in
        x86_64)
            chown -R root:root $RLXOS/lib64
            ;;
    esac

    touch $RLXOS/tools/ownership
}


[[ -f $RLXOS/tools/vfs ]] || {
    mkdir -p $RLXOS/{dev,proc,sys,run}

    mknod -m 600 $RLXOS/dev/console c 5 1
    mknod -m 666 $RLXOS/dev/null c 1 3
    touch $RLXOS/tools/vfs
}

