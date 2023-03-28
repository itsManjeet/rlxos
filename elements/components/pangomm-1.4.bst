kind: meson
sources:
- kind: tar
  url: gnome_downloads:pangomm/2.46/pangomm-2.46.3.tar.xz
  ref: 410fe04d471a608f3f0273d3a17d840241d911ed0ff2c758a9859c66c6f24379
build-depends:
- components/graphviz.bst
- components/mm-common.bst
- freedesktop-sdk.bst:components/doxygen.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/m4.bst
- freedesktop-sdk.bst:components/perl-xml-parser.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/cairomm-1.0.bst
- components/glibmm-2.4.bst
- components/pango.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dmaintainer-mode=true
    -Dbuild-documentation=true
    -Dwarnings=min
