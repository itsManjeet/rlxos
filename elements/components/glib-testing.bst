kind: meson

sources:
- kind: tar
  url: tecnocode:libglib-testing-0.1.0.tar.xz

  ref: cf1e72007ce656a4e23432ac61082f7b87a9baaed57c4b0b0bf872ce7e2fb6e7
build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
