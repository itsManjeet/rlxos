kind: autotools

sources:
- kind: tar
  url: github_files:ostreedev/ostree/releases/download/v2023.2/libostree-2023.2.tar.xz
  ref: ceb0788755a0bff5738d44543552fbf883cf71df481baa3ca7288da7a402bb85
- kind: patch
  path: patches/ostree/no-boot-symlink.patch

build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/git-minimal.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:components/avahi.bst
- freedesktop-sdk.bst:components/curl.bst
- freedesktop-sdk.bst:components/e2fsprogs.bst
- freedesktop-sdk.bst:components/fuse.bst
- freedesktop-sdk.bst:components/gpgme.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/libarchive.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:components/dracut.bst

variables:
  conf-local: >-
    --with-curl
    --with-dracut
    --with-libsystemd
    --with-systemd
    --with-libarchive
    --with-avahi
    --without-selinux
    --without-soup

public:
  bst:
    split-rules:
      devel:
        (>):
        - "%{libdir}/libostree.so"

config:
  install-commands:
    (>):
    - |
      mkdir -p "%{install-root}/sysroot"
      ln -s sysroot/ostree "%{install-root}/ostree"
      ln -s var/home "%{install-root}/home"
      rm -rf "%{install-root}/root"
      ln -s var/roothome "%{install-root}/root"
      ln -s run/media "%{install-root}/media"

