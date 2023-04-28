kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-calendar/44/gnome-calendar-44.1.tar.xz
  ref: 30a1b738b670bd124e462468e671187fc0dba5b9ee2af6a8ebd9e7874bf3b77e
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
