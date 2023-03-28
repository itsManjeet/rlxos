kind: meson
sources:
- kind: tar
  url: gnome_downloads:libpeas/1.34/libpeas-1.34.0.tar.xz
  ref: 4305f715dab4b5ad3e8007daec316625e7065a94e63e25ef55eb1efb964a7bf0
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
