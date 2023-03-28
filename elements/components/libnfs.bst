kind: autotools

sources:
- kind: tar
  url: github_files:sahlberg/libnfs/archive/refs/tags/libnfs-4.0.0.tar.gz

  ref: 6ee77e9fe220e2d3e3b1f53cfea04fb319828cc7dbb97dd9df09e46e901d797d
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
