#!/bin/bash

set -e

OUT_NAME=${1:-"stage1"}

INFO_MESG "backing up stage1 $RLXOS_CACHE_DIR/$OUT_NAME.squa"
mksquashfs $RLX $RLXOS_CACHE_DIR/${OUT_NAME}.squa -noappend \
    -e $RLXOS/source/* \
    -e $RLXOS/build/*

INFO_MESG "creating tarball ${RLXOS_CACHE_DIR}/${OUT_NAME}.tar"
tar -pczf "${RLXOS_CACHE_DIR}/${OUT_NAME}.tar" \
    --exclude "./source/*" \
    --exclude "./build/*" \
    --exclude "./tools/*" -C ${RLX} .