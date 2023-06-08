kind: meson
sources:
- kind: tar
  url: gnome_downloads:grilo/0.3/grilo-0.3.16.tar.xz
  ref: 884580e8c5ece280df23aa63ff5234b7d48988a404df7d6bfccd1e77b473bd96
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
