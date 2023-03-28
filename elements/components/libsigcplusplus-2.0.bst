kind: meson
sources:
- kind: tar
  url: gnome_downloads:libsigc++/2.12/libsigc++-2.12.0.tar.xz
  ref: 1c466d2e64b34f9b118976eb21b138c37ed124d0f61497df2a90ce6c3d9fa3b5
build-depends:
- components/graphviz.bst
- components/mm-common.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/doxygen.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/m4.bst
- freedesktop-sdk.bst:components/perl.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dmaintainer-mode=true
    -Dbuild-documentation=true
    -Dvalidation=false
    -Dwarnings=min
