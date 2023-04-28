kind: meson
sources:
- kind: tar
  url: gnome_downloads:baobab/44/baobab-44.0.tar.xz
  ref: 845b63bb9123d74568c8126c571bbc74273483ff920179a2cf1eddbbefa1bfc0
build-depends:
- components/vala.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- components/librsvg.bst
- freedesktop-sdk.bst:bootstrap-import.bst
