kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-logs/45/gnome-logs-45.beta.tar.xz
  ref: 9dbc49ffb27dd2342e8e2fd498af25b5410db23910fc8eff5e6893ac76bb8cae
build-depends:
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/adwaita-icon-theme.bst
- components/gsettings-desktop-schemas.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:bootstrap-import.bst
