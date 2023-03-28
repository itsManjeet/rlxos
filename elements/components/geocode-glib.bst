kind: meson

sources:
- kind: tar
  url: gnome_downloads:geocode-glib/3.26/geocode-glib-3.26.4.tar.xz
  ref: 2d9a6826d158470449a173871221596da0f83ebdcff98b90c7049089056a37aa
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/json-glib.bst
- components/libsoup.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dsoup2=false
