kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-characters/43/gnome-characters-43.1.tar.xz
  ref: b23e15d950978b363c81a47261ee1a3b47db3c6697ee169ff213eea6572a7841
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
