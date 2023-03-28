kind: meson
sources:
- kind: tar
  url: gnome_downloads:json-glib/1.6/json-glib-1.6.6.tar.xz
  ref: 96ec98be7a91f6dde33636720e3da2ff6ecbb90e76ccaa49497f31a6855a490e
build-depends:
- components/gobject-introspection.bst
- components/gi-docgen.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dgtk_doc=enabled
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libjson-glib-1.0.so'
