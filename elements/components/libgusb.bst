kind: meson

sources:
- kind: tar
  url: freedesktop_people:~hughsient/releases/libgusb-0.3.10.tar.xz
  ref: 0eb0b9ab0f8bba0c59631c809c37b616ef34eb3c8e000b0b9b71cf11e4931bdc
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:components/libusb.bst
- freedesktop-sdk.bst:bootstrap-import.bst
