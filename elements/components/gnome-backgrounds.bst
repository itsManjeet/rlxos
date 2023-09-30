kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-backgrounds/45/gnome-backgrounds-45.0.tar.xz
  ref: cee0e688fbae5ef7a75f335ada2d10779e08ebca9445f1586de32c5a9b6dee2d
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/webp-pixbuf-loader.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
