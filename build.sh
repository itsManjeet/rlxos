#!/bin/bash

#
# Generate System toolchain and packages for rlxos
#

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

FILES=${BASEDIR}/files
REPODB=${BASEDIR}/recipes
PKGSDIR=${BASEDIR}/pkgs
SRCDIR=${BASEDIR}/src
CFLAGS="-march=x86-64 -O2 -pipe"
CXXFLAGS="-march=x86-64 -O2 -pipe"
MAKEFLAGS="-j$(nproc)"

BUILDDIR=${BUILDDIR:-"/var/cache/pkgupd/build"}

[[ -e /dev/tty ]] && INTERACTIVE='-i'
if [[ -z "${NOCONTAINER}" ]]; then
    echo ":: Executing inside container ::"
    docker run \
        --rm \
        --env NOCONTAINER=1 \
        --env DEBUG=1 \
        -v "$(realpath ${0}):/build.sh" \
        -v "${REPODB}:/var/cache/pkgupd/recipes" \
        -v "${PKGSDIR}:/var/cache/pkgupd/pkgs" \
        -v "${SRCDIR}:/var/cache/pkgupd/src" \
        -v "${FILES}:/var/cache/pkgupd/files" \
        -v "${BASEDIR}/build:${BUILDDIR}" \
        -v "${BASEDIR}/pkgupd.yml:/etc/pkgupd.yml" \
        ${INTERACTIVE} --privileged \
        -t itsmanjeet/rlxos-devel:2110 bash /build.sh ${@}
    exit $?
fi

mkdir -p ${PKGSDIR}

RELEASE='continuous'

ARGS=()
while [[ $# -gt 0 ]]; do
    key="${1}"
    case ${key} in
    -r | --release)
        RELEASE="${2}"
        shift
        ;;
    --rebuild)
        REBUILD=1
        shift
        ;;

    --exec)
        EXECUTE="${2}"
        shift
        ;;
    *)
        echo "Error! invalid argument ${key}"
        exit 1
        ;;
    esac
    shift
done

SYS_TOOLCHAIN='kernel-headers glibc binutils gcc binutils glibc'
OUTPUT=${OUTPUT:-"${BUILDDIR}/rlxos-${RELEASE}"}
SYSROOT=${BUILDDIR}/sysroot
DATADIR=${SYSROOT}/var/lib/pkgupd/data

if [[ -n ${EXECUTE} ]] ; then
    echo "Executing: ${EXECUTE}"
    ${EXECUTE}
    exit $?
fi

# Core system package
PACKAGES='iana-etc kernel-headers glibc tzdata zlib bzip2 xz zstd file readline m4 bc flex binutils libgmp libmpfr
libmpc attr acl libcap pam pam-config shadow gcc pkg-config ncurses sed psmisc gettext bison grep bash libtool
gdbm gperf expat inetutils less perl perl-xml-parser intltool autoconf automake kmod libelf libffi openssl python
ninja meson coreutils diffutils gawk findutils groff gzip iptables iproute2 kbd libpipeline make patch tar texinfo
vim py-markupsafe py-jinja2 lz4 systemd dbus man-db procps-ng util-linux e2fsprogs libunistring libidn2 ca-certificates
curl libarchive libuv cmake libyaml-cpp pkgupd grub firmware linux initramfs libburn libisofs libisoburn efivar popt
efibootmgr dosfstools mtools cpio pixman libxml2 lzo squashfs-tools libxslt util-macros xorgproto libxau libxdmcp
xcb-proto libxcb xtrans libx11 libxkbfile xkbcomp xkeyboard-config libxfixes libxdamage libxshmfence libxext libxxf86vm
llvm libpciaccess libdrm wayland wayland-protocols py-mako libva libvdpau libxrender libxrandr mesa libepoxy
xcb-util-keysyms xcb-util xcb-util-image xcb-util-renderutil xcb-util-wm libpng freetype font-util libfontenc mkfontscale
fonts-encodings libxfont2 nettle libevdev mtdev libinput libxi libice libsm libxt libxmu libxpm libxaw libxres libxtst
libxv xorg-server xf86-input-libinput xauth xmodmap xrdb xinit fontconfig pcre glib lzo  cairo yasm libjpeg-turbo sgml-common
unzip docbook-xml itstool docbook-xsl xf86-video-fbdev xmlto shared-mime-info libtiff gobject-introspection gdk-pixbuf
giflib flac opus libogg libvorbis alsa-lib libsndfile sbc libical bluez pulseaudio sdl libwebp imlib2 libxdg-basedir
libxkbcommon lua lua-lgi fribidi libxft graphite2 harfbuzz pango startup-notification xcb-util-cursor xcb-util-xrm xmessage
lcms rustc vala librsvg openjpeg imagemagick awesome'

if [[ ${REBUILD} -eq 1 ]]; then
    for sys in ${SYS_TOOLCHAIN}; do
        echo "=> Generating Toolchain package ${sys}"
        pkgupd co ${sys} --force
        if [[ $? != 0 ]]; then
            echo "Error! Failed to generate ${sys}"
            exit 1
        fi
    done
fi

[[ ${REBUILD} ]] && FORCE='--force'

for pkg in ${PACKAGES}; do
    echo "=> Compiling ${pkg}"
    pkgupd co ${pkg} ${FORCE}
    if [[ $? != 0 ]]; then
        echo "Error! failed to compile package ${pkg}"
        exit 1
    fi
    if [[ ${pkg} == 'docbook-xsl' ]]; then
        version=1.79.2

        [ -f /etc/xml/catalog ] || xmlcatalog --noout --create /etc/xml/catalog

        for ver in $version current; do
            for x in rewriteSystem rewriteURI; do
                xmlcatalog --noout --add $x http://cdn.docbook.org/release/xsl/$ver \
                    /usr/share/xml/docbook/xsl-stylesheets-$version /etc/xml/catalog

                xmlcatalog --noout --add $x http://docbook.sourceforge.net/release/xsl-ns/$ver \
                    /usr/share/xml/docbook/xsl-stylesheets-$version /etc/xml/catalog

                xmlcatalog --noout --add $x http://docbook.sourceforge.net/release/xsl/$ver \
                    /usr/share/xml/docbook/xsl-stylesheets-nons-$version /etc/xml/catalog
            done
        done
    fi
done

mkdir -p ${SYSROOT} ${DATADIR}

for pkg in ${CORESYSTEM} ${EXTRAPKGS} ${BOOTPACKAGES}; do
    echo "=> Installing core system package ${pkg}"
    pkgupd in ${pkg} sys-db=${DATADIR} root-dir=${SYSROOT}
    if [[ $? != 0 ]]; then
        echo "Error! failed to install ${pkg}"
        exit 1
    fi
done

echo ":: Generating tar package ::"
tar --zstd -caf ${OUTPUT}.rootfs -C ${SYSROOT} .
if [[ $? != 0 ]]; then
    echo "Error! failed to generate tar archive"
    exit 1
fi

rm ${OUTPUT}.sys

echo "inside root"
chroot ${SYSROOT} bash << "EOT"
pwconv
grpconv
echo -e "rlxos\nrlxos" | passwd
EOT
echo ":: Generating System Image ::"
mksquashfs ${SYSROOT}/* ${OUTPUT}.sys
if [[ $? != 0 ]] ; then
    echo "Error! failed to generate system Image"
    exit 1
fi

echo ":: Generating ISO ::"
_iso_dir='/tmp/rlxos-iso'
mkdir -p ${_iso_dir}/boot/grub
echo "default='rlxos installer'
timeout=5
menuentry 'rlxos installer' {
    linux /boot/vmlinuz iso=1 root=LABEL=RLXOS system=${VERSION}
    initrd /boot/initrd
}" > ${_iso_dir}/boot/grub/grub.cfg

cp /boot/vmlinuz ${_iso_dir}/boot/vmlinuz

mkinitramfs -k=$(ls /lib/modules) -o=${_iso_dir}/boot/initrd
cp ${OUTPUT}.sys ${_iso_dir}/rootfs.img

grub-mkrescue -volid RLXOS ${_iso_dir} -o ${OUTPUT}.iso

rm -rf ${SYSROOT} ${DATADIR}
