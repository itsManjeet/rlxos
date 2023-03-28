kind: script

build-depends:
- components/libostree.bst
- components/qemu.bst
- system/repo.bst
- freedesktop-sdk.bst:integration/mtab.bst
- freedesktop-sdk.bst:components/genimage.bst
- freedesktop-sdk.bst:snap-images/squashfs-tools.bst

variables:
  sysroot: "/sysroot"

environment:
  OSTREE_REPO: "%{sysroot}/ostree/repo"
  XZFLAGS: -T%{max-jobs}

environment-nocache:
- XZFLAGS

config:
  layout:
  - element: ''
    destination: '/sysroot'
  - element: system/repo.bst
    destination: '/source-repo'
  - element: components/libostree.bst
    destination: '/'
  - element: components/qemu.bst
    destination: '/'
  - element: integration/mtab.bst
    destination: '/'
  - element: components/genimage.bst
    destination: '/'
  - element: snap-images/squashfs-tools.bst
    destination: '/'

  commands:
  - mkdir -p "${OSTREE_REPO}"
  - ostree init --repo="${OSTREE_REPO}" --mode=bare

  - ostree config --group sysroot set bootloader none
  - ostree pull-local "/source-repo" %{ostree-branch}

  - mkdir -p "%{sysroot}/boot"

  - ostree admin init-fs "%{sysroot}"
  - ostree admin os-init --sysroot="%{sysroot}" rlxos
  - |
    ostree admin deploy --os="rlxos" \
         --sysroot="%{sysroot}" %{ostree-branch} \
         --karg="rw" --karg="quiet" --karg="splash" \
         --karg="console=tty0"

  - |
    ostree admin set-origin --sysroot="%{sysroot}" \
           --index=0 \
           rlxos %{ostree-remote-url} \
           %{ostree-branch}

  - |
    # rlxos will be provided in /etc
    ostree remote delete rlxos

  - |
    cp -r "%{sysroot}"/ostree/boot.1/rlxos/*/*/boot/EFI/ "%{sysroot}/boot/"

  - |
    mksquashfs %{sysroot} %{install-root}/rlxos.sfs -b 1048576 -comp xz -Xdict-size 100%