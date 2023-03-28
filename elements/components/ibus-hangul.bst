kind: autotools
sources:
- kind: tar
  url: github_files:libhangul/ibus-hangul/releases/download/1.5.4/ibus-hangul-1.5.4.tar.gz
  ref: a9f27ef9b0c03fd9f2faa327fb0a83c04098763969548b65b2f8159bed15cfe0
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/ibus-daemon.bst
- components/libhangul.bst
- freedesktop-sdk.bst:bootstrap-import.bst
