kind: autotools
sources:
- kind: tar
  url: ftp_gnu_org:libcdio/libcdio-2.1.0.tar.bz2
  ref: 8550e9589dbd594bfac93b81ecf129b1dc9d0d51e90f9696f1b2f9b2af32712b
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  conf-local: >-
    --without-cdda-player
