kind: meson
sources:
- kind: tar
  url: gnome_downloads:libpeas/2.0/libpeas-2.0.0.tar.xz
  ref: 297cb9c2cccd8e8617623d1a3e8415b4530b8e5a893e3527bbfd1edd13237b4c
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/gjs.bst
- components/glib.bst
- components/pygobject.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dpython3=true
    -Dintrospection=true
    -Dlua51=false
    -Dvapi=true
    -Dgtk_doc=true
