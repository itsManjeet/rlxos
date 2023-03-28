kind: ostree

build-depends:
- components/libostree.bst
- system/filesystem.bst
- system/initial-scripts.bst
- freedesktop-sdk.bst:vm/prepare-image.bst

variables:
  uuidnamespace: aea54278-2587-4075-ae67-8688ace4ce3d

config:
  environment:
  - components/libostree.bst
  - vm/prepare-image.bst
  - system/initial-scripts.bst
  ostree-branch: '%{ostree-branch}'
  initial-commands:
  - |
    prepare-image.sh \
       --sysroot %{sysroot} \
       --seed "%{uuidnamespace}" \
       --rootsource /dev/gpt-auto-root \
       --efisource LABEL=EFI \
       --efipath /boot >/dev/null

  - rm %{sysroot}/etc/fstab

  - mv %{sysroot}/etc %{sysroot}/usr/etc
