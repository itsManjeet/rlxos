kind: meson
sources:
- kind: tar
  url: gnome_downloads:baobab/43/baobab-43.0.tar.xz
  ref: 52c6864118f5697f5a5736882dcda27db22e7220bc492838deecc699246cdb26
build-depends:
- components/appstream-glib.bst
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
