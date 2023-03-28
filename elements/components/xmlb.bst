kind: meson

sources:
- kind: tar
  url: github_files:hughsie/libxmlb/archive/refs/tags/0.3.7.tar.gz

  ref: fc00cdb2af69eb4a53bf6a48874c9004ee5373579eafa1dc4e53dace8b9d1251
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dstemmer=false
