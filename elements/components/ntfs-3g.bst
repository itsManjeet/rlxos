kind: autotools

sources:
- kind: tar
  url: github_files:tuxera/ntfs-3g/archive/refs/tags/2021.8.22.tar.gz

  ref: 5cb9fa93bf2b9685e3f1b598861f6082786e76562989a5752c7379dbe0e989a2
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:components/libgcrypt.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --disable-ldconfig

config:
  install-commands:
    (>):
    - ln -s ntfs-3g %{install-root}%{bindir}/mount.ntfs
