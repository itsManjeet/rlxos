kind: meson

sources:
- kind: tar
  url: gnome_downloads:pygobject/3.46/pygobject-3.46.0.tar.xz
  ref: 426008b2dad548c9af1c7b03b59df0440fde5c33f38fb5406b103a43d653cafc
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/pycairo.bst
- freedesktop-sdk.bst:bootstrap-import.bst
