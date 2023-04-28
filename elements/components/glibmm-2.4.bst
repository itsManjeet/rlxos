kind: meson
sources:
- kind: tar
  url: gnome_downloads:glibmm/2.66/glibmm-2.66.6.tar.xz
  ref: 5358742598181e5351d7bf8da072bf93e6dd5f178d27640d4e462bc8f14e152f
build-depends:
- components/graphviz.bst
- components/mm-common.bst
- freedesktop-sdk.bst:components/doxygen.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/m4.bst
- freedesktop-sdk.bst:components/perl-xml-parser.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/libsigcplusplus-2.0.bst
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dmaintainer-mode=true
    -Dbuild-documentation=true
    -Dwarnings=min
