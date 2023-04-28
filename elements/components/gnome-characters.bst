kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-characters/44/gnome-characters-44.0.tar.xz
  ref: 05b15c028cc190aef92e6092fd84fa8d5f2448e0e9076446a3566f3a081ff50b
build-depends:
- components/appstream-glib.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/adwaita-icon-theme.bst
- components/gjs.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:bootstrap-import.bst
