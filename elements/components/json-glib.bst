kind: meson
sources:
- kind: tar
  url: gnome_downloads:json-glib/1.8/json-glib-1.8.0.tar.xz
  ref: 97ef5eb92ca811039ad50a65f06633f1aae64792789307be7170795d8b319454
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
