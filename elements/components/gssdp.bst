kind: meson

sources:
- kind: tar
  url: gnome_downloads:gssdp/1.6/gssdp-1.6.2.tar.xz
  ref: 410b376deeced9836b57f488f80052fe4a14f89e075b1ceccf28e51f490f9fb9
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/libsoup.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dsniffer=false
    -Dmanpages=false
