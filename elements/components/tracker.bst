kind: meson

sources:
- kind: tar
  url: gnome_downloads:tracker/3.6/tracker-3.6.0.tar.xz
  ref: 52592cfe19baffd16dbe47475be7da750dbd0b6333fd7acb60faa9da5bc40df2
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- components/pygobject.bst
- freedesktop-sdk.bst:components/asciidoc.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/json-glib.bst
- components/libsoup.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/icu.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Ddocs=false
    -Dunicode_support=icu
    -Dstemmer=disabled
