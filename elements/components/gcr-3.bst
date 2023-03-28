kind: meson

sources:
- kind: tar
  url: gnome_downloads:gcr/3.41/gcr-3.41.1.tar.xz
  ref: bb7128a3c2febbfee9c03b90d77d498d0ceb237b0789802d60185c71c4bea24f
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/gtk+-3.bst
- components/libsecret.bst
- freedesktop-sdk.bst:components/gnupg.bst
- freedesktop-sdk.bst:components/openssh.bst
- freedesktop-sdk.bst:components/p11-kit.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dssh_agent=false

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgck-1.so'
        - '%{libdir}/libgcr-3.so'
        - '%{libdir}/libgcr-base-3.so'
        - '%{libdir}/libgcr-ui-3.so'
