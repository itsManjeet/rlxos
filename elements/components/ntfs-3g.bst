kind: autotools

sources:
- kind: tar
  url: https://tuxera.com/opensource/ntfs-3g_ntfsprogs-2022.10.3.tgz

  ref: f20e36ee68074b845e3629e6bced4706ad053804cbaf062fbae60738f854170c
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:components/libgcrypt.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --disable-ldconfig

config:
  configure-commands:
    (<):
    - sed 's|$(DESTDIR)/sbin|$(DESTDIR)/usr/bin|' -i {ntfsprogs,src}/Makefile.in
  install-commands:
    (>):
    - ln -s ntfs-3g %{install-root}%{bindir}/mount.ntfs
