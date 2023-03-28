kind: meson

depends:
- components/gnome-shell.bst
- components/pygobject.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

sources:
- kind: tar
  url: gnome_downloads:gnome-browser-connector/42/gnome-browser-connector-42.1.tar.xz
  ref: bd9702ce1c163606ca32b8c13d1f3ba6e82b247cf87aac60610b411df1556212
