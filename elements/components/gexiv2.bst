kind: meson

sources:
- kind: tar
  url: gnome_downloads:gexiv2/0.14/gexiv2-0.14.2.tar.xz

  ref: 2a0c9cf48fbe8b3435008866ffd40b8eddb0667d2212b42396fdf688e93ce0be
build-depends:
- components/pygobject.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/exiv2.bst
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
