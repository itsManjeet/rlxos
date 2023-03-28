kind: autotools
sources:
- kind: tar
  url: github_files:thkukuk/rpcsvc-proto/archive/v1.4.2.tar.gz
  ref: 9f309fa25507836b0c5de8a9d755c1428bde5554610bf92eb21e32078134aef5
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  autogen: |
    autoreconf -fvi
