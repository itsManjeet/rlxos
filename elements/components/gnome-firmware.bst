kind: meson

sources:
- kind: tar
  url: https://people.freedesktop.org/~hughsient/releases/gnome-firmware-43.0.tar.xz
  ref: 1623f29289724f2965caf949e740e0924d36dd7bbdf2d8fa32fedb487e575575
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

variables:
  meson-local: >-
    -Dman=false


depends:
- components/gtk.bst
- components/glib.bst
- components/fwupd.bst
- components/libadwaita.bst
- components/xmlb.bst
- freedesktop-sdk.bst:components/systemd.bst
