kind: meson

sources:
- kind: tar
  url: freedesktop_software:colord/releases/colord-gtk-0.3.0.tar.xz

  ref: b9466656d66d9a6ffbc2dd04fa91c8f6af516bf9efaacb69744eec0f56f3c1d0
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:components/perl-xml-parser.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/colord.bst
- components/glib.bst
- components/gtk+-3.bst
- components/gtk.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dman=false
    -Dvapi=true
