kind: autotools

sources:
- kind: tar
  url: https://www.infradead.org/openconnect/download/openconnect-8.10.tar.gz

  ref: 30e64c6eca4be47bbf1d61f53dc003c6621213738d4ea7a35e5cf1ac2de9bab1
variables:
  conf-local: >-
    --with-vpnc-script=/usr/share/vpnc-scripts

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/gnutls.bst
- components/vpnc-scripts.bst
