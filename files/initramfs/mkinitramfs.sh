#!/bin/bash
#
# rlx-init
# Copyright (C) 2020 rlxos

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# Based on https://wiki.gentoo.org/wiki/Custom_Initramfs/Examples
#

ROOT=
CRYPT_ROOT=
RESUME=

BINARIES="sh bash cat cp dd ls mkdir mknod mount \
         umount sed sleep ln ldd rm uname readlink basename \
         modprobe kmod insmod lsmod blkid \
         blkid dmesg findfs tail head \
         switch_root losetup touch install chroot agetty \
         truncate df awk mkfs.ext4 mkfs mkfs.ext2 mkfs.ext3
         udevadm killall cut md5sum"

INITRD_DIR=$(mktemp -d /tmp/initramfs.XXXXXXXXXX)
INIT_IN=${INIT_IN:-'/usr/share/initramfs/init.in'}
KERNEL=${KERNEL:-$(uname -r)}
PASSWORD='rlxos'
unsorted=$(mktemp /tmp/unsorted.XXXXXXXXXX)
AOUT=${AOUT:-"/boot/initrd"}

export LC_ALL=C

debug() {
    [[ -z $DEBUG ]] && return
    echo -e "\033[1;32m$@\033[00m"
}

warn() {
    echo -e "\033[1;33m$@\033[00m"
}

error() {
    echo -e "\033[1;31m$@\033[00m"
    cleanup
    exit 1
}

cleanup() {
    rm -rf "${INITRD_DIR}"
    rm -f "${unsorted}"
}

# copy src dst mode
#    | src
#    | src dst
# copy src file to dst destination with mode
copy() {
    debug "copy $@"

    src=$1
    dst=$2

    if [[ "${src:0:1}" != "/" ]]; then
        src="/$src"
    fi

    if [ -z "${dst}" ]; then
        dst=${src/\//}
    fi

    if [[ ! -e "${src}" ]]; then
        warn "file not found: $src"
    fi

    mode=${3:-$(stat -c %a "${src}")}
    [[ -z "$mode" ]] && {
        warn "failed to get file mode: $src"
        return
    }

    install -Dm${mode} $src "${INITRD_DIR}/$dst"

}

# install_binary bin
# install binary into initrd
install_binary() {
    ldd $1 2>/dev/null | sed 's/\t//' | cut -d ' ' -f1 >>$unsorted
    copy $1
}

# install_libraries
# install libraries required by binaries installed from $(install_binary)
install_libraries() {

    copy /usr/lib/ld-linux-x86-64.so.2
    copy /usr/lib/systemd/libsystemd-shared-249.so

    sort $unsorted | uniq | while read library; do
        if [[ "$library" == linux-vdso.so.1 ]] ||
            [[ "$library" == linux-gate.so.1 ]] ||
            [[ "$library" =~ ld-linux-x86-64.so.2 ]] ||
            [[ "$library" =~ libsystemd-shared-249.so ]]; then

            continue
        fi
        copy usr/lib/$library

        #[[ $library =~ "/lib/" ]] || library="/lib/$library"
        #copy $library lib/
    done

}

# parse_cmdline_args $@
# parse arguments
parse_args() {
    for p in $@; do
        case "${p}" in
        -k=* | --kernel=*)
            KERNEL=${p#*=}
            ;;

        -i=* | --init=*)
            INIT_IN=${p#*=}
            ;;

        -o=* | --out=*)
            AOUT=${p#*=}
            ;;

        -p=* | --password=*)
            PASSWORD=${p#*=}
            ;;

        -u)
            UNIVERSAL=1
            ;;

        esac
    done
}

# prepare_structure
# prepare required dirs, files and nodes
prepare_structure() {
    mkdir -p -- "${INITRD_DIR}/"{dev,etc,mnt/root,proc,sys,run}
    mkdir -p -- "${INITRD_DIR}/"usr/{bin,lib,share}

    ln -s usr/bin ${INITRD_DIR}/bin
    ln -s usr/bin ${INITRD_DIR}/sbin
    ln -s usr/bin ${INITRD_DIR}/usr/sbin
    ln -s usr/lib ${INITRD_DIR}/lib
    ln -s usr/lib ${INITRD_DIR}/lib64
    ln -s lib ${INITRD_DIR}/usr/lib64

    #copy /dev/console /dev/
    #copy /dev/null /dev/

    for i in $BINARIES; do
        install_binary /usr/bin/$i
    done

    # installing init
    install -m755 "${INIT_IN}" "${INITRD_DIR}/init"
}

# install_udev
# install udev daemon for dynamic module loading
# required when booting from non native system (iso, live booting)
install_udev() {

    copy /lib/systemd/systemd-udevd

    for i in ata_id scsi_id cdrom_id mtd_probe v4l_id; do
        install_binary /usr/lib/udev/${i}
    done

    for i in /usr/lib/udev/rules.d/*.rules; do
        copy $i
    done

}

# install_modules
# install extra kernel modules
install_modules() {

    local REQMODULES="crypto fs lib"
    local DRIVERS="block ata md firewire input scsi message pcmcia virtio hid usb/host usb/storage"

    for mod in ${REQMODULES}; do
        FTGT="${FTGT} /usr/lib/modules/${KERNEL}/kernel/${mod}"
    done
    for driver in ${DRIVERS}; do
        FTGT="${FTGT} /usr/lib/modules/${KERNEL}/kernel/drivers/${driver}"
    done

    # mkdir -p $INITRD_DIR/usr/lib/modules/$KERNEL/

    local loaded_module=$(lsmod | tail -n+2 | awk '{print $1}')
    for module in $(find ${FTGT} -type f -name "*.ko*" 2>/dev/null); do
        if [[ -z ${UNIVERSAL} ]]; then
            if [[ ${loaded_module} =~ $(basename ${module%*.ko*}) ]]; then
                copy ${module}
            fi
        else
            copy ${module}
        fi
    done

    copy /usr/lib/modules/$KERNEL/kernel/fs/isofs/isofs.ko.xz
    copy /usr/lib/modules/$KERNEL/kernel/drivers/cdrom/cdrom.ko.xz
    copy /usr/lib/modules/$KERNEL/kernel/drivers/scsi/sr_mod.ko.xz
    copy /usr/lib/modules/$KERNEL/kernel/fs/overlayfs/overlay.ko.xz
    copy /usr/lib/modules/$KERNEL/kernel/fs/hfsplus/hfsplus.ko.xz
    copy /usr/lib/modules/$KERNEL/kernel/drivers/parport/parport.ko.xz

    for i in /usr/lib/modules/$KERNEL/modules.*; do
        copy $i
    done
}

# install password file
# generate password md5sum
install_password() {
    echo "${PASSWORD}" | md5sum | cut -d ' ' -f1 >${INITRD_DIR}/.secure
}

# compress_initrd
# install required libraries
# compress initrd
# change mode to 400
compress_initrd() {

    install_libraries

    (
        cd "${INITRD_DIR}"
        find . | LANG=C cpio -o -H newc --quiet | gzip -9
    ) >"${AOUT}"

}

function main() {

    parse_args $@

    echo "generating initrd $KERNEL"
    prepare_structure

    install_udev
    install_modules
    install_password
    compress_initrd

    cleanup
}

# main $@

KERNEL="5.4.0-86-generic"
install_modules
