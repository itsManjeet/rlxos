#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh

echo "installing pkgupd"
pkgupd install pkgupd force=true

export PKGUPD_NO_PROGRESS=1
$@