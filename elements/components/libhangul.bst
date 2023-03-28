kind: autotools
sources:
- kind: tar
  url: https://kldp.net/hangul/release/3442-libhangul-0.1.0.tar.gz
  ref: 5905aa5c557d8d46e190fec1afdd75babf3bc086ef286b42007572703658295a
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
