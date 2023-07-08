#!/bin/bash

set -ex

[[ $(whoami) != "$RLXOS_USR" ]] && {
    INFO_MESG "Switching to '$RLXOS_USR'"
    exec sudo -u $RLXOS_USR -H bash -c "${0} ${@}"
    #exit 1
}

INFO_MESG "Executing As '$(whoami)'"

export PATH=$RLXOS/tools:$PATH

_PDIR=$(pwd)

if [[ -z "$1" ]] ; then
    for _s in binutils gcc-static headers glibc libstdc++ m4 ncurses bash  \
              coreutils diffutils file findutils gawk grep gzip make patch \
              sed tar xz binutils-pass2 gcc-final; do
        cd $_PDIR &>/dev/null || true
        INFO_MESG "checking $_s"
        [[ -f $RLXOS/tools/$_s ]] && {
            INFO_MESG "skipping $_s (already configured)"
            continue
        }

        INFO_MESG "compiling toolchain $_s"
        . stage1/${_s}.sh
        if [[ "$?" -ne 0 ]] ; then
            ERR_MESG "failed to compile $_s"
            exit 1
        fi

        touch $RLXOS/tools/$_s

    done

else
    INFO_MESG "executing $1"
    . $1
fi
