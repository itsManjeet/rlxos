#!/bin/sh

set -eu

BASEDIR="$(dirname $(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
))"

VERSION='2209'

xchroot() {
    local _dir=${1}
    shift

    sudo mount /dev ${_dir}/dev --bind
    sudo mount /sys ${_dir}/sys --bind
    sudo mount -t proc proc ${_dir}/proc

    sudo chroot ${_dir} $@
    ret=${?}

    sleep 1

    sudo umount ${_dir}/{dev,sys,proc}

    return $ret
}

_build_dir=${BASEDIR}/build/squashfs

[[ -d ${_build_dir} ]] && {
    echo "clearing cache"
    rm -rf ${_build_dir}
}

mkdir -p ${_build_dir}

echo "
dir:
    recipes: ${BASEDIR}/recipes
    pkgs: ${BASEDIR}/pkgs
    data: ${_build_dir}/var/lib/pkgupd/data
    root: ${_build_dir}
" >${BASEDIR}/build/pkgupd.yml

pushd ${BASEDIR}/build
fakeroot pkgupd install dev.rlxos.core
popd

rm -f ${BASEDIR}/build/root.sfs

fakeroot mksquashfs ${_build_dir} ${BASEDIR}/build/root.sfs \
    -b 1048576 -comp xz -Xdict-size 100%
if [[ $? -ne 0 ]]; then
    echo "failed to pack rootfs"
    exit 1
fi

rm -f ${BASEDIR}/build/iso.sfs

#
# add autologin
sed 's#--noclear#--noclear --autologin root#' $_build_dir/etc/inittab >${BASEDIR}/overlay/etc/inittab
fakeroot mksquashfs ${BASEDIR}/overlay ${BASEDIR}/build/iso.sfs \
    -b 1048576 -comp xz -Xdict-size 100%
if [[ $? -ne 0 ]]; then
    echo "failed to pack overlay"
    exit 1
fi

_kernel_ver=$(ls ${_build_dir}/usr/lib/modules | head -n1)

xchroot ${_build_dir} mkinitramfs -k=${_kernel_ver}

_iso_dir=${BASEDIR}/build/iso

[[ -d ${_iso_dir} ]] && {
    echo "cleaning cache"
    rm -rf ${_iso_dir}
}

mkdir -p ${_iso_dir}/boot/grub
cp ${BASEDIR}/build/squashfs/boot/{initrd,vmlinuz} ${_iso_dir}/boot/
cp ${BASEDIR}/build/root.sfs ${_iso_dir}/rootfs.img
cp ${BASEDIR}/build/iso.sfs ${_iso_dir}/iso.img

echo "
set default=0
set timeout=99

insmod all_video

if loadfont /boot/grub/fonts/unicode.pf2 ; then
    set gfxmode=800x600
    insmod efi_gop
    insmod efi_uga
    insmod video_bochs
    insmod video_cirrus
    insmod gfxterm
    insmod png
    terminal_output gfxterm
fi

if background_image /boot/grub/splash.png ; then
    set color_normal=light-gray/black
    set color_highlight=white/black
else
    set color_normal=cyan/blue
    set color_highlight=white/blue
fi

menuentry 'rlxos installer' {
    linux /boot/vmlinuz root=LABEL=RLXOS iso=1 quiet
    initrd /boot/initrd
}

menuentry 'rlxos installer [debug]' {
    linux /boot/vmlinuz root=LABEL=RLXOS iso=1 debug rescue delay=2
    initrd /boot/initrd
}" >${_iso_dir}/boot/grub/grub.cfg

grub-mkrescue -o rlxos-${VERSION}-core-$(uname -m).iso ${_iso_dir} -volid RLXOS

sudo rm -rf ${_build_dir} ${_iso_dir}
