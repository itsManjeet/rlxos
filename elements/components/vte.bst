kind: meson

sources:
- kind: tar
  url: gnome_downloads:vte/0.74/vte-0.74.0.tar.xz
  ref: 9ae08f777952ba793221152d360550451580f42d3b570e3341ebb6841984c76b
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/gtk+-3.bst
- components/gtk.bst
- freedesktop-sdk.bst:components/fribidi.bst
- freedesktop-sdk.bst:components/gnutls.bst
- freedesktop-sdk.bst:components/icu.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dgtk4=true
    -Ddocs=true
    -Dglade=false

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libvte-2.91.so'
