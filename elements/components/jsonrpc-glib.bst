kind: meson

depends:
- components/json-glib.bst

build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

sources:
- kind: tar
  url: gnome_downloads:jsonrpc-glib/3.44/jsonrpc-glib-3.44.0.tar.xz
