kind: meson

sources:
- kind: tar
  url: gnome_downloads:libhandy/1.8/libhandy-1.8.2.tar.xz
  ref: d11aa2cd3e570ac6d0efdba46d173147c11f45826457e924c05990bb2e0df9ad
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dgtk_doc=true
    -Dvapi=true
    -Dtests=true
    -Dexamples=false
    -Dglade_catalog=disabled
