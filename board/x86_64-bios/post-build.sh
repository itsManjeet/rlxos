#!/bin/sh

set -e

BOARD_DIR=$(dirname "$0")

cp -f "$BOARD_DIR/grub.cfg" "$TARGET_DIR/boot/grub/grub.cfg"
cp -f "$TARGET_DIR/lib/grub/i386-pc/boot.img" "$BINARIES_DIR"
