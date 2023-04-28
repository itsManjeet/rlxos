kind: meson

sources:
- kind: tar
  url: gnome_downloads:pygobject/3.44/pygobject-3.44.1.tar.xz
  ref: 3c6805d1321be90cc32e648215a562430e0d3d6edcda8f4c5e7a9daffcad5710
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/pycairo.bst
- freedesktop-sdk.bst:bootstrap-import.bst
