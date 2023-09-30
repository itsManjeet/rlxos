kind: meson

sources:
- kind: tar
  url: gnome_downloads:gtksourceview/5.10/gtksourceview-5.10.0.tar.xz
  ref: b38a3010c34f59e13b05175e9d20ca02a3110443fec2b1e5747413801bc9c23f
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
