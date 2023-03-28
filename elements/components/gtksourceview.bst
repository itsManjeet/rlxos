kind: meson

sources:
- kind: tar
  url: gnome_downloads:gtksourceview/5.6/gtksourceview-5.6.2.tar.xz
  ref: 1f146c156f135a60499d979e3577c99b6e15a111445767abe6219bb34c545c77
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/sysprof-minimal.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gtk.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dinstall_tests=true
    -Dgtk_doc=true
    -Dsysprof=true
