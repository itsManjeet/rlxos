kind: meson
sources:
- kind: tar
  url: gnome_downloads:gtkmm/3.24/gtkmm-3.24.7.tar.xz
  ref: 1d7a35af9c5ceccacb244ee3c2deb9b245720d8510ac5c7e6f4b6f9947e6789c
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
