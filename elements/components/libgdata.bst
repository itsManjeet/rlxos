kind: meson
sources:
- kind: tar
  url: gnome_downloads:libgdata/0.18/libgdata-0.18.1.tar.xz
  ref: dd8592eeb6512ad0a8cf5c8be8c72e76f74bfe6b23e4dd93f0756ee0716804c7
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/gnome-online-accounts.bst
- components/liboauth.bst
- components/uhttpmock.bst
- components/gcr-3.bst
- components/glib.bst
- components/json-glib.bst
- components/libsoup-2.4.bst
- freedesktop-sdk.bst:bootstrap-import.bst
