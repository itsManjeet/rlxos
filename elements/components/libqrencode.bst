kind: autotools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/libpng.bst

sources:
- kind: tar
  url: github_files:fukuchi/libqrencode/archive/refs/tags/v4.1.1.tar.gz
  ref: 5385bc1b8c2f20f3b91d258bf8ccc8cf62023935df2d2676b5b67049f31a049c
