#!/bin/bash

set -e

[[ "$UID" -eq 0 ]] || {
    INFO_MESG "Need superuser permission to prepare environment"
    exec sudo "$0" "$@"
    exit 0
}

INFO_MESG "Executing As '$(whoami)'"

_PDIR=$(pwd)

_xmount() {
    [[ -d $RLXOS/dev ]] || {
        mkdir -pv $RLXOS/{dev,proc,sys,run}
    }
    mount | grep -q $RLXOS/dev/pts || {
        INFO_MESG "mounting pseudo file system"
        mount -v --bind /dev $RLXOS/dev
        mount -v --bind /dev/pts $RLXOS/dev/pts
        mount -vt proc proc $RLXOS/proc
        mount -vt sysfs sysfs $RLXOS/sys
        mount -vt tmpfs tmpfs $RLXOS/run
    }
}

_xchroot() {
    _xmount

    INFO_MESG "Executing $@ in chroot"

    chroot "$RLX" /usr/bin/env -i \
        HOME=/root \
        TERM="$TERM" \
        PS1='(rlx chroot)\u:\w\$ ' \
        RLXOS='/' \
        RLXOS_BUILD_DIR='/build' \
        RLXOS_SRC='/source' \
        PATH=/bin:/usr/bin:/sbin:/usr/sbin \
        $@
    _xumount
}

_xumount() {
    INFO_MESG "unmounting pseudo filesystem"
    umount $RLXOS/{dev/pts,proc,sys,run,dev}
}

__prepare_fs() {
    cat <<EOF | chroot $RLX
    mkdir -pv /{boot,home,mnt,opt,srv}
    mkdir -pv /etc/{opt,sysconfig}
    mkdir -pv /{usr,opt}/{bin,include,lib,src}
    mkdir -pv /{usr,opt}/share/{color,dict,info,locale,man}
    mkdir -pv /{usr,opt}/share/{misc,terminfo,zoneinfo}
    mkdir -pv /{usr,opt}/share/man/man{1..8}
    mkdir -pv /var/{cache,local,log,mail,opt,spool}
    mkdir -pv /var/lib/{color,misc,locate}
    ln -sv usr/bin bin
    ln -sv usr/bin sbin
    ln -sv bin usr/sbin
    ln -sv usr/lib lib
    ln -sv usr/lib lib64
    ln -sv lib usr/lib64

    ln -sfv /run /var/run
    ln -sfv /run/lock /var/lock

    install -vdm0750 /root
    install -vdm1777 /tmp /var/tmp
EOF
}

__prepare_links() {
    cat <<EOF | chroot $RLX

ln -sv /proc/self/mounts /etc/mtab

echo "127.0.0.1 localhost localhost" > /etc/hosts
touch /var/log/{btmp,lastlog,faillog,wtmp}
EOF

    cat >$RLXOS/etc/resolv.conf <<"EOF"
nameserver 8.8.8.8
EOF

    echo "127.0.0.1 localhost $(hostname)" >$RLXOS/etc/hosts
    cat >$RLXOS/etc/passwd <<"EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

    cat >$RLXOS/etc/group <<"EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
wheel:x:97:
nogroup:x:99:
users:x:999:
EOF

}

PrepareFS() {
    if [[ ! -d $RLXOS/root ]]; then
        __prepare_fs
    fi

    if [[ ! -L $RLXOS/etc/mtab ]]; then
        __prepare_links
    fi

    [[ -f $RLXOS/.config.sh ]] || {
        cp .config.sh $RLXOS/

        sed -i 's|RLXOS=.*|RLXOS="/"|' $RLXOS/.config.sh
        sed -i 's|PATH=.*|PATH=/bin:/sbin:/usr/bin:/usr/sbin|' $RLXOS/.config.sh
    }
    cp ver.sh $RLXOS/ver.sh
}

PrepareFS

export -f INFO_MESG

. ver.sh
GETTEXT_SRC_FLDR="gettext-$GETTEXT_VERSION"
BISON_SRC_FLDR="bison-$BISON_VERSION"
PERL_SRC_FLDR="perl-$PERL_VERSION"
PYTHON_SRC_FLDR="Python-$PYTHON_VERSION"
TEXINFO_SRC_FLDR="texinfo-$TEXINFO_VERSION"
UTILLINUX_SRC_FLDR="util-linux-$UTILLINUX_VERSION"
OPENSSL_SRC_FLDR="openssl-$OPENSSL_VERSION"
PKG_CONFIG_FLDR="pkg-config-$PKG_CONFIG_VERSION"
WGET_SRC_FLDR="wget-$WGET_VERSION"
CMAKE_SRC_FLDR="cmake-$CMAKE_VERSION"
LIBARCHIVE_SRC_FLDR="libarchive-$LIBARCHIVE_VERSION"
LIBYAML_CPP_SRC_FLDR="yaml-cpp-$LIBYAML_CPP_VERSION"
PKGUPD_SRC_FLDR="pkgupd-$PKGUPD_VERSION"

for i in "http://ftp.gnu.org/gnu/gettext/$GETTEXT_SRC_FLDR.tar.xz" \
    "http://ftp.gnu.org/gnu/bison/$BISON_SRC_FLDR.tar.xz" \
    "https://www.cpan.org/src/5.0/$PERL_SRC_FLDR.tar.xz" \
    "https://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_SRC_FLDR.tar.xz" \
    "http://ftp.gnu.org/gnu/texinfo/$TEXINFO_SRC_FLDR.tar.xz" \
    "https://www.kernel.org/pub/linux/utils/util-linux/v${UTILLINUX_VERSION:0:4}/$UTILLINUX_SRC_FLDR.tar.xz" \
    "https://www.openssl.org/source/$OPENSSL_SRC_FLDR.tar.gz" \
    "https://pkg-config.freedesktop.org/releases/$PKG_CONFIG_FLDR.tar.gz" \
    "http://ftp.gnu.org/gnu/wget/$WGET_SRC_FLDR.tar.gz" \
    "https://github.com/Kitware/CMake/archive/refs/tags/v$CMAKE_VERSION.tar.gz" \
    "https://github.com/libarchive/libarchive/releases/download/v${LIBARCHIVE_VERSION}/$LIBARCHIVE_SRC_FLDR.tar.xz" \
    "https://github.com/jbeder/yaml-cpp/archive/refs/tags/$LIBYAML_CPP_SRC_FLDR.tar.gz" \
    "https://github.com/itsManjeet/pkgupd/archive/refs/heads/${PKGUPD_VERSION}.tar.gz"; do
    
    [[ -e ${RLX}/source/$(basename ${i}) ]] && continue

    wget --continue --directory-prefix=$RLXOS/source $i
done

if [[ -z "$1" ]]; then
    for _s in test_file libstdc++ gettext bison perl \
        python texinfo utillinux openssl pkg-config wget zstd curl \
        cmake libarchive libyaml-cpp pkgupd; do
        cd $_PDIR &>/dev/null
        INFO_MESG "checking $_s"
        [[ -f $RLXOS/tmp/$_s ]] && {
            INFO_MESG "skipping $_s (already configured)"
            continue
        }

        INFO_MESG "compiling toolchain $_s"
        _xchroot /bin/bash <stage2/${_s}.sh
        if [[ "$?" -ne 0 ]]; then
            ERR_MESG "failed to compile $_s"
            exit 1
        fi

        touch $RLXOS/tmp/$_s

    done

    strip --strip-debug $RLXOS/usr/lib/* || true
    strip --strip-unneeded $RLXOS/usr/bin/* || true
    strip --strip-unneeded $RLXOS/tools/bin/* || true

    INFO_MESG "backing up system"
    . stage1/backup.sh "stage2"

else
    INFO_MESG "executing $1"
    _xchroot /bin/bash <${1}
fi
