kind: meson
sources:
- kind: tar
  url: gnome_downloads:libdazzle/3.44/libdazzle-3.44.0.tar.xz
  ref: 3cd3e45eb6e2680cb05d52e1e80dd8f9d59d4765212f0e28f78e6c1783d18eae
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:bootstrap-import.bst
