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
         udevadm killall cut md5sum unzstd zstd setsid"

INITRD_DIR=$(mktemp -d /tmp/initramfs.XXXXXXXXXX)
INIT_IN=${INIT_IN:-'/usr/share/initramfs/init.in'}
KERNEL=${KERNEL:-$(uname -r)}
PASSWORD='rlxos'
unsorted=$(mktemp /tmp/unsorted.XXXXXXXXXX)
MODULES_DIR='/boot/modules'

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
    systemd_version=$(PKGUPD_NO_MESSAGE=1 pkgupd info systemd info.value=version)
    if [[ $? != 0 ]] ; then
        echo "Error! failed to get systemd version: ${systemd_version}"
        cleanup
        exit 1
    fi
    systemd_version=${systemd_version%%-*}
    copy /usr/lib/ld-linux-x86-64.so.2
    copy /usr/lib/systemd/libsystemd-shared-${systemd_version}.so

    sort $unsorted | uniq | while read library; do
        if [[ "$library" == linux-vdso.so.1 ]] ||
            [[ "$library" == linux-gate.so.1 ]] ||
            [[ "$library" =~ ld-linux-x86-64.so.2 ]] ||
            [[ "$library" =~ libsystemd-shared-${systemd_version}.so ]]; then

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
            echo ":: using kernel ${KERNEL}"
            ;;

        -i=* | --init=*)
            INIT_IN=${p#*=}
            echo ":: using init ${INIT_IN}"
            ;;

        -o=* | --out=*)
            AOUT=${p#*=}
            echo ":: output ${AOUT}"
            ;;

        -p=* | --password=*)
            PASSWORD=${p#*=}
            ;;

        -m=* | --modules-dir=*)
            MODULES_DIR=${p#*=}
            echo ":: using modules dir ${MODULES_DIR}"
            ;;

        --no-plymouth)
            NO_PLYMOUTH=1
            echo ":: disabling plymouth support"
            ;;

        -u)
            UNIVERSAL=1
            echo ":: generating universal initrd"
            ;;

        esac
    done
}

# prepare_structure
# prepare required dirs, files and nodes
prepare_structure() {
    mkdir -p -- "${INITRD_DIR}/"{dev,boot/modules,etc,mnt/root,proc,sys,run}
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
        FTGT="${FTGT} ${MODULES_DIR}/${KERNEL}/kernel/${mod}"
    done
    for driver in ${DRIVERS}; do
        FTGT="${FTGT} ${MODULES_DIR}/${KERNEL}/kernel/drivers/${driver}"
    done

    mkdir -p $INITRD_DIR/boot/modules/$KERNEL/

    copy_module() {
        local _src_path=${1}
        local _dest_path=$(echo ${1} | sed "s|${MODULES_DIR}|/boot/modules|g")
        copy ${_src_path} ${_dest_path}
    }

    local loaded_module=$(lsmod | tail -n+2 | awk '{print $1}')
    for module in $(find ${FTGT} -type f -name "*.ko*" 2>/dev/null); do
        if [[ -z ${UNIVERSAL} ]]; then
            if [[ ${loaded_module} =~ $(basename ${module%*.ko*}) ]]; then
                copy_module ${module}
            fi
        else
            copy_module ${module}
        fi
    done
    
    for i in ${MODULES_DIR}/$KERNEL/modules.*; do
        copy_module $i
    done

    ext=$(modinfo -k ${KERNEL} isofs | grep filename | awk '{print $2}' | rev | cut -d '.' -f1 | rev)
    copy_module ${MODULES_DIR}/$KERNEL/kernel/fs/isofs/isofs.ko.${ext}
    copy_module ${MODULES_DIR}/$KERNEL/kernel/drivers/cdrom/cdrom.ko.${ext}
    copy_module ${MODULES_DIR}/$KERNEL/kernel/drivers/scsi/sr_mod.ko.${ext}
    copy_module ${MODULES_DIR}/$KERNEL/kernel/fs/overlayfs/overlay.ko.${ext}
    copy_module ${MODULES_DIR}/$KERNEL/kernel/fs/hfsplus/hfsplus.ko.${ext}
    copy_module ${MODULES_DIR}/$KERNEL/kernel/drivers/parport/parport.ko.${ext}

    # regenerate dependency list
    depmod -b ${INITRD_DIR} ${KERNEL}
}

# installing plymouth
install_plymouth() {
    mkdir -p ${INITRD_DIR}/dev/pts
    mkdir -p ${INITRD_DIR}/usr/share/plymouth/themes
    mkdir -p ${INITRD_DIR}/run/plymouth

    local DATADIR="/usr/share/plymouth"
    local PLYMOUTH_LOGO_FILE="${DATADIR}/rlxos-logo.png"
    local PLYMOUTH_THEME_NAME="$(plymouth-set-default-theme)"
    local PLYMOUTH_THEME_DIR="${DATADIR}/themes/${PLYMOUTH_THEME_NAME}"
    local PLYMOUTH_IMAGE_DIR=$(grep "ImageDir *= *" ${PLYMOUTH_THEME_DIR}/${PLYMOUTH_THEME_NAME}.plymouth | sed 's/ImageDir *= *//')
	local PLYMOUTH_PLUGIN_PATH="$(plymouth --get-splash-plugin-path)"
	local PLYMOUTH_MODULE_NAME="$(grep "ModuleName *= *" ${PLYMOUTH_THEME_DIR}/${PLYMOUTH_THEME_NAME}.plymouth | sed 's/ModuleName *= *//')"

    install_binary /usr/bin/plymouth
    install_binary /usr/bin/plymouthd
    install_binary /usr/lib/plymouth/plymouthd-fd-escrow

    copy ${DATADIR}/themes/text/text.plymouth
    install_binary ${PLYMOUTH_PLUGIN_PATH}/text.so
    copy ${DATADIR}/themes/details/details.plymouth
    install_binary ${PLYMOUTH_PLUGIN_PATH}/details.so

    copy ${PLYMOUTH_LOGO_FILE}
    copy /etc/os-release
    copy /etc/plymouth/plymouthd.conf
    copy ${DATADIR}/plymouthd.defaults

    if [ -f "/usr/share/fonts/dejavu/DejaVuSans.ttf" -o -f "/usr/share/fonts/cantarell/Cantarell-Thin.otf" ] ; then
        install_binary ${PLYMOUTH_PLUGIN_PATH}/label.so
        copy "/etc/fonts/fonts.conf"
    fi

    if [ -f "/usr/share/fonts/dejavu/DejaVuSans.ttf" ] ; then
        copy "/usr/share/fonts/dejavu/DejaVuSans.ttf"
    fi

    if [ -f "/usr/share/fonts/cantarell/Cantarell-Thin.otf" ] ; then
        copy "/usr/share/fonts/cantarell/Cantarell-Thin.otf"
    fi

    if [ ! -f ${PLYMOUTH_PLUGIN_PATH}/${PLYMOUTH_MODULE_NAME}.so ] ; then
        echo "Error! plymouth default theme ${PLYMOUTH_THEME_NAME} not exists"
        cleanup
        exit 1
    fi

    install_binary ${PLYMOUTH_PLUGIN_PATH}/${PLYMOUTH_MODULE_NAME}.so
    install_binary ${PLYMOUTH_PLUGIN_PATH}/renderers/drm.so
    install_binary ${PLYMOUTH_PLUGIN_PATH}/renderers/frame-buffer.so

    if [ -d ${PLYMOUTH_THEME_DIR} ] ; then
        cp -r ${PLYMOUTH_THEME_DIR} ${INITRD_DIR}/${PLYMOUTH_THEME_DIR}
    fi

    if [ "${PLYMOUTH_IMAGE_DIR}" != "${PLYMOUTH_THEME_DIR}" -a -d ${PLYMOUTH_IMAGE_DIR} ] ; then
        copy ${PLYMOUTH_IMAGE_DIR}
    fi

    copy /usr/lib/udev/rules.d/70-uaccess.rules
    copy /usr/lib/udev/rules.d/71-seat.rules

    copy /etc/passwd
    copy /etc/nsswitch.conf

    install_binary "$(readlink -e /lib/libnss_files.so.2)"
    copy /lib/libnss_files.so.2
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
    
    AOUT=${AOUT:-"/boot/initrd-${KERNEL}"}
    
    (
        cd "${INITRD_DIR}"
        find . | LANG=C cpio -o -H newc --quiet | zstd -14 -f -o "${AOUT}"
    )

}

function main() {

    parse_args $@

    echo "generating initrd $KERNEL"
    prepare_structure

    install_udev
    install_modules
    install_plymouth
    install_password
    compress_initrd

    cleanup
}

main $@
