kind: meson

sources:
- kind: tar
  url: gnome_downloads:gexiv2/0.14/gexiv2-0.14.1.tar.xz

  ref: ec3ee3ec3860b9c78958a55da89cf76ae2305848e12f41945b7b52124d8f6cf9
build-depends:
- components/pygobject.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/exiv2.bst
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
