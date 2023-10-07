kind: autotools

sources:
- kind: tar
  url: github_files:libpinyin/libpinyin/releases/download/2.8.1/libpinyin-2.8.1.tar.gz
  ref: 353154f06d71dd0737b77ddcb27cb0dcaddb00f7ccd695bc0314bb42050e9050
- kind: tar
  url: sourceforge:libpinyin/models/model17.text.tar.gz
  base-dir: ''
  directory: data

  ref: e017278ab022bca065a744ccbbede94db8932ec3fb64592a1693627db9b662cd
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/glib.bst
- components/kyotocabinet.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  conf-local: >-
    --with-dbm=KyotoCabinet
  notparallel: true
