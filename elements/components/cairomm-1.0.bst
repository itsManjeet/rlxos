kind: meson
sources:
- kind: tar
  url: cairo:releases/cairomm-1.14.4.tar.xz
  ref: 4749d25a2b2ef67cc0c014caaf5c87fa46792fc4b3ede186fb0fc932d2055158
build-depends:
- components/graphviz.bst
- components/mm-common.bst
- freedesktop-sdk.bst:components/doxygen.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/perl.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/libsigcplusplus-2.0.bst
- freedesktop-sdk.bst:components/cairo.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dmaintainer-mode=true
    -Dbuild-documentation=true
    -Dwarnings=min
