kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-backgrounds/43/gnome-backgrounds-43.rc.tar.xz
  ref: d308e008b87914a8761229c43dd8607a646a05ec0c497366386e5c7ef531086d
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/webp-pixbuf-loader.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
