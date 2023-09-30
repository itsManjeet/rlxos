kind: meson

sources:
- kind: tar
  url: gnome_downloads:libcloudproviders/0.3/libcloudproviders-0.3.4.tar.xz

  ref: e3d7160c3e45fe3216c07c7988bb4fc81397c32d1fc6113af0edfe8632039f65
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
