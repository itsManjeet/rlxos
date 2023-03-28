kind: meson
sources:
- kind: tar
  url: gnome_downloads:grilo/0.3/grilo-0.3.15.tar.xz
  ref: f352acf73665669934270636fede66b52da6801fe20f638c4048ab2678577b2d
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/totem-pl-parser.bst
- components/glib.bst
- components/gtk+-3.bst
- components/libsoup-2.4.bst
- freedesktop-sdk.bst:bootstrap-import.bst
