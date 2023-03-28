kind: autotools

sources:
- kind: tar
  url: github_files:ostreedev/ostree/releases/download/v2022.5/libostree-2022.5.tar.xz
  ref: 914c4d993bc111d7dd30ae9721b6ffe8ab56eb1fd6e81b097b09f400cc1b053f
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

