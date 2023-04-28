kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-backgrounds/44/gnome-backgrounds-44.0.tar.xz
  ref: 4a8393b387135f2a6a424a1a0c3ac94e0742b62b8235a0923c929f51e04be04e
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/webp-pixbuf-loader.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
