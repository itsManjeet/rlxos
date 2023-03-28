kind: meson
sources:
- kind: tar
  url: gnome_downloads:gom/0.4/gom-0.4.tar.xz
  ref: 68d08006aaa3b58169ce7cf1839498f45686fba8115f09acecb89d77e1018a9d
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/gdk-pixbuf.bst
- components/glib.bst
- components/pygobject.bst
- freedesktop-sdk.bst:bootstrap-import.bst
