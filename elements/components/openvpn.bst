kind: autotools

sources:
- kind: tar
  url: https://swupdate.openvpn.org/community/releases/openvpn-2.5.1.tar.gz

  ref: e9582b8e9457994bd8d50012be82c23b2f465da51460c9b2360a81da0f4e06e6
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/git-minimal.bst

depends:
- freedesktop-sdk.bst:components/lz4.bst
- freedesktop-sdk.bst:components/lzo.bst
- freedesktop-sdk.bst:components/linux-pam.bst
- freedesktop-sdk.bst:components/openssl.bst
