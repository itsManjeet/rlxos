kind: meson
sources:
- kind: tar
  url: gnome_downloads:libgweather/4.4/libgweather-4.4.0.tar.xz
  ref: 366e866ff2a708b894cfea9475b8e8ff54cb3e2b477ea72a8ade0dabee5f48a4
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- components/gi-docgen.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/geocode-glib.bst
- components/glib.bst
- components/libsoup.bst
- components/pygobject.bst
- freedesktop-sdk.bst:bootstrap-import.bst
