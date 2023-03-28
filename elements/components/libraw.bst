kind: autotools

sources:
- kind: tar
  url: libraw:data/LibRaw-0.20.2.tar.gz

  ref: dc1b486c2003435733043e4e05273477326e51c3ea554c6864a4eafaff1004a6
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:components/lcms.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --disable-examples
