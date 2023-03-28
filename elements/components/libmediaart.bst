kind: meson
sources:
- kind: tar
  url: gnome_downloads:libmediaart/1.9/libmediaart-1.9.6.tar.xz
  ref: c3bc5025d7db380587f9c8eb800c611f6b5a16d6b4b78fcff93f62876a677f17
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/gdk-pixbuf.bst
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: |
    -Dimage_library=gdk-pixbuf
