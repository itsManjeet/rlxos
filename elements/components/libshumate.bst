kind: meson

sources:
- kind: tar
  url: gnome_downloads:libshumate/1.0/libshumate-1.0.3.tar.xz
  ref: 77a192f0dfec082b8de20b1939f3adf03eed41114d49fdaae2bbb2729ceb015a
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/gtk.bst
- components/libsoup.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dlibsoup3=true
