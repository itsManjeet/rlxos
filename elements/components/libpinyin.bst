kind: autotools

sources:
- kind: tar
  url: github_files:libpinyin/libpinyin/releases/download/2.6.1/libpinyin-2.6.1.tar.gz
  ref: fc42c4820c0e1609788bbfaf693dcb6265a3caf2aa963b20e7a994054a528b51
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
