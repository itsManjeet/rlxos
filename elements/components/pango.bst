kind: meson
sources:
- kind: tar
  url: gnome_downloads:pango/1.51/pango-1.51.0.tar.xz
  ref: 74efc109ae6f903bbe6af77eaa2ac6094b8ee245a2e23f132a7a8f0862d1a9f5
build-depends:
- components/gobject-introspection.bst
- components/gi-docgen.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- components/json-glib.bst
- freedesktop-sdk.bst:components/cairo.bst
- freedesktop-sdk.bst:components/fontconfig.bst
- freedesktop-sdk.bst:components/fribidi.bst
- freedesktop-sdk.bst:components/harfbuzz.bst
- freedesktop-sdk.bst:components/libthai.bst
- freedesktop-sdk.bst:components/xorg-lib-xft.bst
- freedesktop-sdk.bst:bootstrap-import.bst
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libpango-1.0.so'
        - '%{libdir}/libpangocairo-1.0.so'
        - '%{libdir}/libpangoft2-1.0.so'
variables:
  meson-local: >-
    -Dgtk_doc=true
    -Dlibthai=disabled
    -Dxft=disabled
