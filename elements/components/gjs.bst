kind: meson

sources:
- kind: tar
  url: gnome_downloads:gjs/1.76/gjs-1.76.0.tar.xz
  ref: a63f156964b136053eab51ea013114e7d7c193b7518d28c040b6b02c3c933a6d
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
