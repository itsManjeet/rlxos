variables:
  force-rebuild: true
  strip: false
script: |-
  mkdir -p /sysroot
  mkdir -p %{build-root}/stage-1
  mkdir -p %{build-root}/stage-2
  mkdir -p %{build-root}/iso/LiveOS
  mkdir -p %{build-root}/images

  ostree admin init-fs --modern /sysroot
  ostree admin os-init --sysroot=/sysroot rlxos

  ostree config --repo=/sysroot/ostree/repo set sysroot.bootloader none

  ostree pull-local --repo=/sysroot/ostree/repo %{include-root} %{ostree-branch}

  ostree admin deploy \
    --sysroot=/sysroot \
    --os=rlxos  \
    --karg=rd.live=1 \
    --karg=root=live:LABEL=%{installer-volume-id} \
    --karg=rd.live.overlay.overlayfs=1 \
    --karg=console=tty0 \
    --karg=console=ttyS0 \
    %{ostree-branch}

  mkdir -p /sysroot/proc
  install -D -m 644 %{libdir}/systemd/boot/efi/systemd-bootx64.efi /sysroot/boot/EFI/BOOT/BOOTX64.EFI

  cp -ar /sysroot/boot /sysroot/efi
  cp -ar /sysroot/boot %{build-root}/iso/

  cat >%{build-root}/stage-1/genimage.cfg << EOF
  image efi.img {
    mountpoint = "/efi"
    vfat {
      extraargs = "-F 32 -n EFI"
    }
    size = 500M
  }

  image squashfs.img {
    mountpoint = "/"
    squashfs {
      compression = "zstd"
    }
  }

  config {
    rootpath = "/sysroot"
    inputpath = "%{build-root}/images"
    outputpath = "%{build-root}/images"
  }
  EOF

  cat >%{build-root}/stage-2/genimage.cfg << EOF
  image rlxos-%{arch}-%{version}.iso {
    iso {
      extraargs = "-isohybrid-mbr %{datadir}/syslinux/isohdpfx.bin -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e /efi.img -no-emul-boot -isohybrid-gpt-basdat -sysid LINUX -publisher rlxos"
      volume-id = "%{installer-volume-id}"
    }
  }

  config {
    rootpath = "%{build-root}/iso"
    inputpath = "%{build-root}/images"
    outputpath = "%{build-root}/images"
    genisoimage = "xorrisofs"
  }
  EOF

  (cd %{build-root}/stage-1; genimage)

  mv %{build-root}/images/squashfs.img %{build-root}/iso/LiveOS
  mv %{build-root}/images/efi.img %{build-root}/iso

  mkdir -p %{build-root}/iso/isolinux/
  for file in chain.c32 isolinux.bin ldlinux.c32 libutil.c32 reboot.c32 vesamenu.c32 libcom32.c32 poweroff.c32 ; do
    cp %{datadir}/syslinux/$file %{build-root}/iso/isolinux/
  done

  # read ostree config
  getconfig() {
    cat /sysroot/boot/loader/entries/ostree-1-rlxos.conf | grep "$1" | cut -d ' ' -f2-
  }

  install -vDm0644 /dev/stdin %{build-root}/iso/isolinux/isolinux.cfg << EOF
  DEFAULT $(getconfig title)
  LABEL $(getconfig title)
    KERNEL /boot/$(getconfig linux)
    APPEND initrd=/boot/$(getconfig initrd) $(getconfig options)
  EOF

  (cd %{build-root}/stage-2; genimage)

  mv %{build-root}/images/rlxos-%{arch}-%{version}.iso %{install-root}

  cd %{install-root}
  sha256sum rlxos-%{arch}-%{version}.iso >rlxos-%{arch}-%{version}.iso.sha265sum

build-depends:
  - components/e2fsprogs.yml
  - components/dracut.yml
  - components/ostree.yml
  - components/mtools.yml
  - components/grub.yml
  - components/systemd.yml
  - components/cryptsetup.yml
  - components/squashfs-tools.yml
  - components/syslinux.yml
  - components/plymouth.yml
  - components/genimage.yml