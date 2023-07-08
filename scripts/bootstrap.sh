#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BASEDIR="$(dirname ${SCRIPTPATH})"

. ${SCRIPTPATH}/ver.sh


export RLXOS_ARCH="${RLXOS_ARCH:-x86_64}"

case "$RLXOS_ARCH" in
    x86_64|i686)
        export RLXOS_TGT="$RLXOS_ARCH-rlxos-linux-gnu"
        export CARCH='x86-64'
    ;;
    
    # armv7l|armv6l|aarch64)
    #     export RLXOS_TGT="$RLXOS_ARCH-rlxos-linux-musleabihf"
    #     export CARCH=${RLXOS_ARCH}
    #     ;;
esac

function get_environ() {
    cat ${BASEDIR}/config.yml | grep $1 | cut -d '=' -f2-
}

export CFLAGS="$(get_environ CFLAGS)"
export CXXFLAGS="$(get_environ CXXFLAGS)"
export LDFLAGS="$(get_environ LDFLAGS)"
export MAKEFLAGS="$(get_environ MAKEFLAGS)"

export RLXOS_HOST="$(echo $MACHTYPE | sed "s/$(echo $MACHTYPE | cut -d- -f2)/cross/")"
export RLXOS="${BASEDIR}/build/bootstrap/rlxos.$RLXOS_ARCH"
export RLXOS_CACHE_DIR="${BASEDIR}/build/bootstrap/cache.$RLXOS_ARCH"
export RLXOS_SRC_DIR="${BASEDIR}/build/source"
export RLXOS_BUILD_DIR="${BASEDIR}/build"
export RLXOS_PATCHES="${BASEDIR}/patches"
export PATH=$RLXOS/tools/bin:$PATH
export RLXOS_VERSION="2307"
export RLXOS_BUILD_NO=""

export RLXOS_USR="rlxos"

WHITE_COLOR="\033[1;37m"
CYAN_COLOR="\033[1;36m"
RED_COLOR="\033[1;31m"
GREEN_COLOR="\033[1;32m"
NO_COLOR="\033[0m"

INFO_MESG() {
    echo -e "${WHITE_COLOR}[${CYAN_COLOR}Info${WHITE_COLOR}]:${NO_COLOR} $@"
}

ERR_MESG() {
    echo -e "${WHITE_COLOR}[${RED_COLOR}Error${WHITE_COLOR}]:${RED_COLOR} $@${NO_COLOR}"
}

SUCCESS_MESG() {
    echo -e "${WHITE_COLOR}[${GREEN_COLOR}Success${WHITE_COLOR}]:${GREEN_COLOR} $@${NO_COLOR}"
}

RLXOS_DOWNLOAD() {
    FILENAME=$(basename $1)
    [[ -z "$2" ]] || FILENAME="$2"
    URL=$1
    [[ -f $RLXOS_SRC_DIR/$FILENAME ]] || {
        [[ -f $RLXOS_SRC_DIR/$FILENAME.part ]] && RESUME="-c"
        INFO_MESG "Downloading $FILENAME from $URL"
        wget $RESUME --passive-ftp --tries=3 --waitretry=3 --output-document=$RLXOS_SRC_DIR/$FILENAME.part $URL --no-check-certificate &&    \
        mv $RLXOS_SRC_DIR/$FILENAME{.part,}
    }
}

RLXOS_EXTRACT() {
    [[ -d $RLXOS_BUILD_DIR ]] && rm -rf $RLXOS_BUILD_DIR/*
    
    mkdir -p $RLXOS_BUILD_DIR
    
    INFO_MESG "Extracting $1 -> $RLXOS_BUILD_DIR"
    tar -xf $RLXOS_SRC_DIR/$1 -C $RLXOS_BUILD_DIR/ || {
        ERR_MESG "Failed to extract $1"
        exit 1
    }
}


set -e

_AVL_ARCH="x86_64 i686 armv7l armv6l aarch64"

is_arch() {
    for i in $_AVL_ARCH; do
        [[ "${1}" == "${i}" ]] && return 0
    done
    
    return 1
}

check_prepare() {
    if [[ ! -d "$RLXOS" ]]; then
        INFO_MESG "preparing system for first start"
        . ${BASEDIR}/bootstrap/stage1/prepare.sh
    fi
}

[[ $(id -u) != "0" ]] && {
    exec sudo bash -c "${0} ${@}"
    exit 1
}

check_prepare

_logo="
       .__
_______|  | ___  ___   ____  ______
\_  __ \  | \  \/  /  /  _ \/  ___/
|  | \/  |__>    <  (  <_> )___ \
|__|  |____/__/\_ \  \____/____  >
                 \/            \/
    Welcome to rlxos bootstrap
-----------------------------------------
Architecture  :  ${RLXOS_ARCH}
Target        :  ${RLXOS_TGT}
Host          :  ${RLXOS_HOST}
Roots         :  ${RLX}
Version       :  ${RLXOS_VERSION}"

echo "$_logo"

INFO_MESG "compiling stage1"
. ${BASEDIR}/bootstrap/stage1/stage1.sh
[[ $? -ne 0 ]] && {
    ERR_MESG "failed to compile stage1"
    exit 1
}

. ${BASEDIR}/bootstrap/stage2/prepare.sh
INFO_MESG "compiling stage2"
. ${BASEDIR}/bootstrap/stage2/stage2.sh
[[ $? -ne 0 ]] && {
    ERR_MESG "failed to compile stage2"
    exit 1
}
