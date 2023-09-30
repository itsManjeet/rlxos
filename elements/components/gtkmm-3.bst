kind: meson
sources:
- kind: tar
  url: gnome_downloads:gtkmm/3.24/gtkmm-3.24.8.tar.xz
  ref: d2940c64922e5b958554b23d4c41d1839ea9e43e0d2e5b3819cfb46824a098c4
build-depends:
- components/graphviz.bst
- components/mm-common.bst
- freedesktop-sdk.bst:components/doxygen.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/m4.bst
- freedesktop-sdk.bst:components/perl-xml-parser.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/atkmm-1.6.bst
- components/cairomm-1.0.bst
- components/pangomm-1.4.bst
- components/glibmm-2.4.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dmaintainer-mode=true
    -Dbuild-documentation=true
    -Dwarnings=min
