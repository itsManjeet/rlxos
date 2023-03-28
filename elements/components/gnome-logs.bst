kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-logs/43/gnome-logs-43.0.tar.xz
  ref: 33a93b975ec27c8487825048aa7b8af7d5c23565abcf7b74c902ab7b3ec20861
build-depends:
- components/appstream-glib.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/adwaita-icon-theme.bst
- components/gsettings-desktop-schemas.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:bootstrap-import.bst
