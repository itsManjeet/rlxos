kind: meson
sources:
- kind: tar
  url: gnome_downloads:pango/1.50/pango-1.50.14.tar.xz
  ref: 1d67f205bfc318c27a29cfdfb6828568df566795df0cb51d2189cde7f2d581e8
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
