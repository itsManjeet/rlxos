kind: autotools

sources:
- kind: tar
  url: github_files:libimobiledevice/libplist/releases/download/2.2.0/libplist-2.2.0.tar.bz2

  ref: 4a5517e5377ec421df84c586ba85bb4e1d26f11ad203d7d450a907c0156fbd9a
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --without-cython
