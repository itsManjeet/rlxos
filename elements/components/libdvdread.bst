kind: autotools
sources:
- kind: tar
  url: videolan:pub/videolan/libdvdread/6.1.3/libdvdread-6.1.3.tar.bz2
  ref: ce35454997a208cbe50e91232f0e73fb1ac3471965813a13b8730a8f18a15369
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
