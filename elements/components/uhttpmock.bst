kind: autotools
sources:
- kind: tar
  url: tecnocode:uhttpmock/uhttpmock-0.5.3.tar.xz
  ref: 90843223c3a30bdb7f1eb3442373a03fee425af85a9df289cd687698ccff112f
build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/glib.bst
- components/libsoup-2.4.bst
- freedesktop-sdk.bst:bootstrap-import.bst
