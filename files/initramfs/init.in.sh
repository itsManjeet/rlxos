#!/bin/bash
#
# init.in
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

export PATH=/bin:/sbin:/usr/bin:/usr/sbin

RESET='\033[0m'
BLACK='\033[1;30m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BBOLD='\033[1m'

generate_hash() {
    echo "${1}" | md5sum | cut -d ' ' -f1
}

# end_with_error 'message'
# Display error message and exit
end_with_error() {
    echo -e "${RED}: ${1}${RESET}"
    sleep 99999
    exit
}

# verify_access
# verify if secure action is valid
verify_access() {
    debug "Verifying security key"

    if [[ -z "${SECURE}" ]]; then
        end_with_error "Need security key to access rescue shell"
    fi

    if [[ ! -e '/.secure' ]]; then
        end_with_error "No security key found"
    fi

    SECURE_HASHSUM="$(cat /.secure)"

    if [[ ${SECURE_HASHSUM} != "$(generate_hash ${SECURE})" ]]; then
        end_with_error "Security key check failed"
    fi

    echo -e "${GREEN} Verification Pass ${RESET}"
}

# reset_system
# reset system delete cache
reset_system() {
    verify_access

    debug "clearing cache directory"
    mkdir -p /run/_root
    mount -o rw ${root} /run/_root

    rm -rvf /run/_root/rlxos/cache
    umount /run/_root
}

# rescue_shell 'fail message'
# drop the boot process into rescue mode for debug
rescue_shell() {
    echo -e "${RED}$1${RESET}\n${YELLOW}Dropping to ${GREEN}resuce${YELLO}shell${RESET}"
    exec sh
}

# debug 'message'
# print debug messages if enable
debug() {
    [[ -z "$DEBUG" ]] && return
    echo -e "${GREEN}debug${RESET}:${BBOLD}$@${RESET}"
}

# mount_filesystem
# mount pseudo filesystems devtmpfs, sysfs, proc
mount_filesystem() {
    mount -t proc none /proc -o nosuid,noexec,nodev || rescue_shell "failed to mount /proc"
    mount -t sysfs none /sys -o nosuid,noexec,nodev || rescue_shell "failed to mount /sys"
    mount -t devtmpfs none /dev -o mode=0755,nosuid || rescue_shell "failed to mount /dev"
    mount -t tmpfs none /run -o nosuid,nodev,mode=0755 || rescue_shell "failed to mount /run"
}

# load_modules
# load required modules if specified in cmdline or if booting from iso
load_modules() {

    # load modules required for booting from squashfs image (cdrom)
    if [[ -n "$squa" ]] || [[ -n "$system" ]]; then
        modules="$modules loop cdrom sr_mod isofs overlay"
    fi

    /lib/systemd/systemd-udevd --daemon --resolve-names=never
    udevadm trigger --action=add --type=subsystems
    udevadm trigger --action=add --type=devices
    udevadm trigger --action=change --type=devices
    udevadm settle

    for m in $modules; do
        modprobe $m || rescue_shell "failed to load $m module"
    done

}

# search_roots
# search roots
search_roots() {
    oldroot=${root}

    root=$(findfs ${root})
    [[ -z "$root" ]] && rescue_shell "failed to find roots from '${oldroot}'"

    # TODO
    # find root device from every block node /dev/? (check for /usr/etc/rlx-release)

}

# prepare_cdrom
# prepare roots from cdrom while booting live system or cdrom
prepare_cdrom() {
    mkdir -p /run/{initramfs,iso}
    # mount iso device (sr0) -> /run/iso
    mount -o ro "${root}" /run/iso || rescue_shell "failed to mount iso ${YELLOW}(squa enabled)${RESET}"

    _squapoint="/run/initramfs/overlay/squa"
    # mount squa image -> ${_squapoint}
    [[ -d "${_squapoint}" ]] || mkdir -p "${_squapoint}"
    [[ -e "/run/iso/${squa}" ]] || rescue_shell "'${squa}' not exist in iso"

    mount -t squashfs "/run/iso/${squa}" "${_squapoint}" || rescue_shell "failed to mount squa ${squa} to ${_squapoint}"

    if [[ -e "/run/iso/${isoverlay}" ]]; then
        _mpoint="/run/initramfs/overlay/isoverlay"
        mkdir -p "${_mpoint}"
        mount -t squashfs "/run/iso/${isoverlay}" "${_mpoint}" || rescule_shell "failed to mount ${isoverlay} to ${_mpoint}"
        extra_point="${_mpoint}:"
    fi

    _lowerdirpoint="${extra_point}${_squapoint}"

    mkdir -p /run/initramfs/overlay/{upper,work}

    rootpoint=/mnt/root
    mkdir -p $rootpoint
    mount -t overlay overlay -o upperdir=/run/initramfs/overlay/upper,lowerdir="${_lowerdirpoint}",workdir=/run/initramfs/overlay/work $rootpoint

    for dir in home boot ; do
        if [[ -d ${rootpoint}/${dir} && ! -L ${rootpoint}/${dir} ]] ; then
            rmdir ${rootpoint}/${dir} || continue
        fi
        if [[ ! -d /run/iso/${dir} ]] ; then
            mkdir -p /run/initramfs/${dir}
            ln -sf /run/initramfs/${dir} ${rootpoint}/${dir}
        else
            ln -sf /run/iso/${dir} ${rootpoint}/${dir}
        fi
    done
}

# mount_root_system
# mount root image like live boot
mount_root_system() {
    diskpoint='/run/initramfs'

    mkdir -p "${diskpoint}"

    # mount root -> diskpoint
    mount -o rw "${root}" ${diskpoint} || rescue_shell "failed to mount ${root} -> ${diskpoint}"

    sysimg="${diskpoint}/rlxos/system/${system}"
    confdir="${diskpoint}/rlxos/config"
    mkdir -p ${confdir}

    # check and mount sysimg
    [[ -e "${sysimg}" ]] || rescue_shell "'${sysimg}' is missing"

    # check cache version
    if [[ -z ${cache} ]] ; then
        if [[ -d ${diskpoint}/rlxos/cache/${system} ]] ; then
            echo "FOUND: image specific cache"
            cache="${system}"
        else
            cache='common'
        fi
    fi

    syspoint="${diskpoint}/rlxos/cache/${cache}/image"
    mkdir -p "${syspoint}"

    mount -t squashfs "${sysimg}" "${syspoint}" || rescue_shell "failed to mount ${sysimg} -> ${syspoint}"

    uprdir="${diskpoint}/rlxos/cache/${cache}/upper"
    wrkdir="${diskpoint}/rlxos/cache/${cache}/work"
    rootpoint="/mnt/root"
    mkdir -p "${uprdir}" "${wrkdir}" "${rootpoint}"

    # disable metacopy and index
    # causing kernel panic: mount system call failed: stale file handle
    mount -t overlay overlay -o index=off -o metacopy=off -o upperdir="${uprdir}",lowerdir="${syspoint}",workdir="${wrkdir}" "${rootpoint}"

    for dir in home boot ; do
        if [[ -d ${rootpoint}/${dir} && ! -L ${rootpoint}/${dir} ]] ; then
            rmdir ${rootpoint}/${dir} || continue
        fi
        ln -sf /run/initramfs/${dir} ${rootpoint}/${dir}
    done
}

# mount_root
# mount root device to /mnt/root
mount_root() {
    [[ -d "${rootpoint}" ]] || mkdir -p "${rootpoint}"
    mount -o rw "${root}" "${rootpoint}" || rescue_shell "failed to mount roots ${root} to /mnt/root"

    system_image="${rootpoint}/sysroot/${system}"
    if [[ -d ${system_image} ]] ; then
        lowerdir=${system_image}
    elif [[ -f ${system_image} ]] ; then
        mkdir -p ${rootpoint}/.squashfs
        mount ${system_image} ${rootpoint}/.squashfs
        lowerdir=${rootpoint}/.squashfs
    else
        rescue_shell "Invalid system=${system}"
    fi

    # check cache version
    if [[ -z ${cache} ]] ; then
        if [[ -d ${rootpoint}/cache/${system} ]] ; then
            echo "FOUND: image specific cache"
            cache="${system}"
        else
            cache='common'
        fi
    fi

    mkdir -p ${rootpoint}/.work

    mount -t overlay overlay \
            -o index=off     \
            -o metacopy=off  \
            -o upperdir="${rootpoint}/cache/${cache}",lowerdir="${lowerdir}",workdir="${rootpoint}/.work" \
            "${rootpoint}/root" || rescue_shell "failed to add overlay layer ${root}"
    
    for dir in home boot ; do
        [[ -d ${rootpoint}/${dir}      ]] || mkdir -p ${rootpoint}/${dir}
        [[ -L ${rootpoint}/root/${dir} ]] && rm ${rootpoint}/root/${dir}
        mkdir -p ${rootpoint}/root/${dir}
        mount --bind ${rootpoint}/${dir} ${rootpoint}/root/${dir}
    done
    rootpoint=${rootpoint}/root
}

# start_plymouth
# check and start plymouth
start_plymouth() {
    if [[ ! -e /usr/bin/plymouthd ]] ; then
        return
    fi

    if [[ -n "${NO_PLYMOUTH}" ]] ; then
        return 
    fi

    udevadm trigger --action=add --attr-match=0x030000 >/dev/null 2>&1
    udevadm trigger --action=add --subsystem-match=graphics --subsystem-match=drm --subsystem-match=tty >/dev/null 2>&1
    udevadm settle --timeout=30 2>&1

    mknod /dev/fb c 29 &>/dev/null
    mkdir -p /dev/pts
    mount -t devpts -o noexec,nosuid,gid=5,mode=0620 devpts /dev/pts || true

    plymouthd --mode=boot --pid-file=/run/plymouth/pid --attach-to-session

    plymouth --show-splash

    PLYMOUTH_STARTED=1
}


# check_resume
# check if resume from hibernation
check_resume() {
    if [ -n "${resume}" ]; then
        debug "resuming from ${resume}"
        printf '%u:%u\n' $(stat -L -c '0x%t 0x%T' "${resume}") >/sys/power/resume ||
            rescue_shell "activating resume failed"
    fi
}

# parse_cmdline_args
# parse linux cmdline args from /proc/cmdline
parse_cmdline_args() {
    for p in $(cat /proc/cmdline); do
        case "${p}" in
        root=*)
            root="${p#*=}"
            ;;

        iso=*)
            ISO=1
            ;;

        isoverlay=*)
            isoverlay="${p#*=}"
            ;;

        squa=*)
            squa="${p#*=}"
            ;;

        resume=*)
            resume="${p#*=}"
            ;;

        ro | rw)
            ro="${p}"
            ;;

        init=*)
            init="${p#*=}"
            ;;

        system=*)
            system="${p#*=}"
            ;;

        cache=*)
            cache="${p#*=}"
            ;;

        secure=*)
            SECURE="${p#*=}"
            ;;

        debug)
            DEBUG=1
            ;;

        RESET)
            SYSTEM_RESET=1
            ;;
        
        no-plymouth)
            NO_PLYMOUTH=1
            ;;
        
        delay=*)
            DELAY="${p#*=}"
            ;;

        rescue)
            RESCUE=1
            ;;
        esac
    done
}

function main() {

    # Default variables
    root=
    resume=
    ro='ro'
    init='/sbin/init'
    squa='/rootfs.img'
    isoverlay='/iso.img'
    rootpoint='/run/sysroot'
    system=

    mount_filesystem
    parse_cmdline_args
    if [[ -n ${ISO} ]] ; then
        if [[ -z ${DELAY} ]] ; then
            DELAY=5
        fi
    fi
    
    [[ -z ${DEBUG}  ]] && dmesg -n1

    debug "loading modules"
    load_modules

    [[ -z ${NO_PLYMOUTH} ]] && start_plymouth

    if [[ -n ${DELAY} ]] ; then
        sleep ${DELAY}
    fi

    debug "searching roots"
    search_roots

    if [[ "${ISO}" ]]; then
        debug "activating iso mode"
        prepare_cdrom
    elif [[ "${system}" ]]; then
        debug "activating disk mode"
        mount_root
    fi

    killall -w /lib/systemd/systemd-udevd

    debug "checking resume"
    check_resume

    [[ -z $RESCUE ]] || rescue_shell

    [[ -n ${PLYMOUTH_STARTED} ]] && {
        plymouth update-root-fs --new-root-dir=${rootpoint}
    }

    exec switch_root "${rootpoint}" "${init}" || rescue_shell "failed to switch roots"
}

main
