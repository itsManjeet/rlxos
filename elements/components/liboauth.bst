kind: autotools

sources:
- kind: tar
  url: sourceforge:liboauth/liboauth-1.0.3.tar.gz

  ref: 0df60157b052f0e774ade8a8bac59d6e8d4b464058cc55f9208d72e41156811f
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:components/nss.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --enable-nss
