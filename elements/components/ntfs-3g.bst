kind: autotools

sources:
- kind: tar
  url: github_files:tuxera/ntfs-3g/archive/refs/tags/2022.10.3.tar.gz

  ref: 8bd7749ea9d8534c9f0664d48b576e90b96d45ec8803c9427f6ffaa2f0dde299
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
