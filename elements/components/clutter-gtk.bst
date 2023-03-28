kind: meson

sources:
- kind: tar
  url: gnome_downloads:clutter-gtk/1.8/clutter-gtk-1.8.4.tar.xz

  ref: 521493ec038973c77edcb8bc5eac23eed41645117894aaee7300b2487cb42b06
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/clutter.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:bootstrap-import.bst

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libclutter-gtk-1.0.so'
