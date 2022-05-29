#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh

pkgupd update mode.ask=false

export PKGUPD_NO_PROGRESS=1
$@