kind: meson
sources:
- kind: tar
  url: gnome_downloads:glibmm/2.66/glibmm-2.66.5.tar.xz
  ref: 7b384662dd6ec3b86c0570331d32af05db2bd99a791602b767b4a0b2566ec149
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
