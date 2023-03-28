kind: meson

sources:
- kind: tar
  url: gnome_downloads:gjs/1.74/gjs-1.74.1.tar.xz
  ref: f21f9cd3337a672a44c7e64bf9a8d8ad77c1b88b952b2b6184c7af9b1f3ef459
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
