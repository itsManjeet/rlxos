kind: meson
sources:
- kind: tar
  url: gnome_downloads:libmanette/0.2/libmanette-0.2.6.tar.xz
  ref: 63653259a821ec7d90d681e52e757e2219d462828c9d74b056a5f53267636bac
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:components/libevdev.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:bootstrap-import.bst
