kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-weather/44/gnome-weather-44.0.tar.xz
  ref: 6b0d38ac785041699df628926e35db7b5ffa086ee0d6934c222a19c6b9923baf
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/libgweather.bst
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/gdk-pixbuf.bst
- components/geoclue.bst
- components/gjs.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
