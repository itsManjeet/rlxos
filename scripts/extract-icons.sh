#!/bin/bash

APPS_DIR=$1
ICONS_DIR=$2

[[ -z ${ICONS_DIR} ]] && {
    echo "Usage: <app-dir> <icons-dir>"
    exit 1
}

mkdir -p ${ICONS_DIR}
cd /tmp/
for i in $APPS_DIR/*.app ; do
    chmod +x $i
    $i --appimage-extract .DirIcon
    original_icon=$(readlink squashfs-root/.DirIcon)
    $i --appimage-extract ${original_icon}
    # case ${i%.*} in
    #     svg)
            
    #         ;;
    #     *)
    #         convert squashfs-root/${original_icon} $ICONS_DIR/$(basename ${i%.*}).svg
    #         ;;
    # esac
    cp squashfs-root/${original_icon} $ICONS_DIR/$(basename ${i%.*}).svg
done