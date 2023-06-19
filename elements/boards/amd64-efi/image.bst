kind: script

build-depends:
- boards/amd64-efi/build-deps.bst
- system/image.bst
- boards/amd64-efi/filesystem.bst
- boards/amd64-efi/initial-scripts.bst
- boards/amd64-efi/initramfs.bst

variables:
  install-root: /build/install-root
  uuidnamespace: aea54278-2587-4075-ae67-8688ace4ce3d

config:
  layout:
  - element: boards/amd64-efi/build-deps.bst
    destination: /
  - element: boards/amd64-efi/filesystem.bst
    destination: /sysroot
  - element: boards/amd64-efi/initramfs.bst
    destination: /sysroot/efi
  - element: boards/amd64-efi/initial-scripts.bst
    destination: /
  - element: system/image.bst
    destination: /rlxos/images/

  commands:
  - mkdir -p /tmp
  - mkdir -p /build/images
  - mkdir -p /build/install-root
  - mkdir -p /build/stage-1
  - mkdir -p /build/stage-2
  - mkdir -p /build/sysroot-stage-2

  - |
    prepare-image.sh \
       --sysroot /sysroot \
       --seed "%{uuidnamespace}" \
       --rootpasswd "root" \
       --rootsource LABEL="%{installer-volume-id}" \
       --rootfstype iso9660 \
       --noboot >/dev/null

  - |
    get_size() {
      size=$(($(du --apparent-size -B 512 -s "${1}" | cut -f1)/2))
      echo $((${size}+(${size}/10)))k
    }
    cat >/build/stage-1/genimage.cfg <<EOF
    image efi.img {
        mountpoint = "/efi"
        vfat {
            extraargs = "-F32 -n EFI"
        }
        size = 500M
    }
    image squashfs.img {
        mountpoint = "/"
        squashfs  {
        }
    }
    config {
        rootpath = "/sysroot"
        inputpath = "/build/images"
        outputpath = "/build/images"
    }
    EOF

  - |
    cat >/build/stage-2/genimage.cfg <<EOF
    image installer.iso {
        iso {
            extraargs = "-e /efi.img -no-emul-boot -boot-load-size 4 -efi-boot-part --efi-boot-image -sysid LINUX -publisher RLXOS"
            volume-id = "%{installer-volume-id}"
        }
    }
    config {
        rootpath = "/build/sysroot-stage-2"
        inputpath = "/build/images"
        outputpath = "/build/images"
        genisoimage = "xorrisofs"
    }
    EOF

  - |
    cd /build/stage-1
    genimage

  - |
    mkdir -p "/build/sysroot-stage-2/LiveOS"
    mv "/build/images/squashfs.img" \
       "/build/sysroot-stage-2/LiveOS/"
    mv "/build/images/efi.img" \
       "/build/sysroot-stage-2/"
    mv "/rlxos/images/rlxos.sfs" \
       "/build/sysroot-stage-2/"

  - |
    cd /build/stage-2
    genimage

  - mv /build/images/installer.iso "%{install-root}/%{installer-volume-id}-efi.iso"
  - |
    cd %{install-root}/
    sha512sum %{install-root}/%{installer-volume-id}-efi.iso > %{install-root}/%{installer-volume-id}-efi.iso.sha512sum
