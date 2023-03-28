kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-autoar/0.4/gnome-autoar-0.4.3.tar.xz
  ref: 7bdf0789553496abddc3c963b0ce7363805c0c02c025feddebcaacc787249e88
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:components/libarchive.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dvapi=true
