kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-calendar/43/gnome-calendar-43.1.tar.xz
  ref: afa5fc66e2f691553cc7d517db2363cff2d62cd1b5df455e5f4f7133139d21f2
build-depends:
- components/appstream-glib.bst
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
