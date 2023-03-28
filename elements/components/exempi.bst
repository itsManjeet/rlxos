kind: autotools
sources:
- kind: tar
  url: libopenraw:download/exempi-2.5.2.tar.bz2
  ref: 52f54314aefd45945d47a6ecf4bd21f362e6467fa5d0538b0d45a06bc6eaaed5
build-depends:
- freedesktop-sdk.bst:components/expat.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/boost.bst
- freedesktop-sdk.bst:bootstrap-import.bst
