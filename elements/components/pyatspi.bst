kind: autotools
sources:
- kind: tar
  url: gnome_downloads:pyatspi/2.46/pyatspi-2.46.0.tar.xz
  ref: d45489cf3d47aa150b1a35e8949b3b31035f8c2075e588d26b6efc625970c62e
build-depends:
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/at-spi2-core.bst
- components/pygobject.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  conf-local: >-
    --with-python=python3
