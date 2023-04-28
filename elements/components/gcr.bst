kind: meson

sources:
- kind: tar
  url: gnome_downloads:gcr/4.1/gcr-4.1.0.tar.xz
  ref: 9ceaad29284ba919b9216e2888c18ec67240c2c93b3a4856bc5488bbc1f3a383
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/gtk+-3.bst
- components/gtk.bst
- components/libsecret.bst
- freedesktop-sdk.bst:components/gnupg.bst
- freedesktop-sdk.bst:components/openssh.bst
- freedesktop-sdk.bst:components/p11-kit.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:bootstrap-import.bst

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgck-2.so'
        - '%{libdir}/libgcr-4.so'
        - '%{libdir}/libgcr-4-gtk3.so'
        - '%{libdir}/libgcr-4-gtk4.so'
