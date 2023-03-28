kind: meson
sources:
- kind: tar
  url: gnome_downloads:libgweather/4.2/libgweather-4.2.0.tar.xz
  ref: af8a812da0d8976a000e1d62572c256086a817323fbf35b066dbfdd8d2ca6203
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- components/gi-docgen.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/geocode-glib.bst
- components/glib.bst
- components/libsoup.bst
- components/pygobject.bst
- freedesktop-sdk.bst:bootstrap-import.bst
