kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-calendar/45/gnome-calendar-45.0.tar.xz
  ref: 8c1483cbba4388db410875ed09d64e9003f929b555d704076a6fe7bd7c1e65b2
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/evolution-data-server.bst
- components/geocode-glib.bst
- components/gnome-online-accounts.bst
- components/libgweather.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
