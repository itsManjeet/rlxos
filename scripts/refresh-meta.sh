#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh

echo "installing pkgupd"
pkgupd update mode.ask=false

pkgupd install squashfs-tools mode.all-yes=true

pkgupd meta