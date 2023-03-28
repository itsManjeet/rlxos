kind: autotools
sources:
- kind: tar
  url: github_files:libpinyin/ibus-libpinyin/releases/download/1.12.1/ibus-libpinyin-1.12.1.tar.gz
  ref: 0c6ec935305fd1a70b9ad467a7f6b353e58ffb3d49f03e459ddec23765db51d7
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/ibus-daemon.bst
- components/libpinyin.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  conf-local: >-
    --disable-lua-extension
    --with-python=python3
