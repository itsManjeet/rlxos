kind: meson

sources:
- kind: tar
  url: gnome_downloads:libdex/0.4/libdex-0.4.0.tar.xz
  ref: 36b027e8a368325be7214b987763b1a3794ed29fb7a938ba6ecd93a3be21c4fb
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- components/liburing.bst
- components/sysprof-minimal.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Ddocs=true
    -Dsysprof=true
