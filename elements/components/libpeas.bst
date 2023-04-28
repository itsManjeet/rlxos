kind: meson
sources:
- kind: tar
  url: gnome_downloads:libpeas/1.36/libpeas-1.36.0.tar.xz
  ref: 297cb9c2cccd8e8617623d1a3e8415b4530b8e5a893e3527bbfd1edd13237b4c
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:components/perl-xml-parser.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- components/gtk+-3.bst
- components/pygobject.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dpython3=true
    -Dintrospection=true
    -Dvapi=true
    -Dwidgetry=true
    -Dgtk_doc=true
