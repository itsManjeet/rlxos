kind: meson

sources:
- kind: tar
  url: gnome_downloads:gjs/1.78/gjs-1.78.0.tar.xz
  ref: fbaa20e0917668830800f92951688f9fc08f01296affd5cdb4b35f750be27dc9
build-depends:
- components/sysprof-minimal.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gobject-introspection.bst
- components/gtk+-3.bst
- components/mozjs.bst
- freedesktop-sdk.bst:components/cairo.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dprofiler=enabled

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgjs.so'
