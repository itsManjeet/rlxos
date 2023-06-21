#!/bin/bash

check() {
    require_binaries /usr/bin/mount
    require_binaries /usr/bin/umount
}

depends() {
    return 0
}

installkernel() {
    instmods overlay
    instmods "=fs/overlayfs"
}

install() {
    dracut_install /usr/bin/mount
    dracut_install /usr/bin/umount
    inst_hook pre-pivot 10 "${moddir}/mount-overlayroot.sh"
}