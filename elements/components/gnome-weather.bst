kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-weather/45/gnome-weather-45.0.tar.xz
  ref: 30c0029702883dc8d8160e6de1d6116877cd6c25bc950d4e4902a6ab467b2fa4
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/libgweather.bst
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/gdk-pixbuf.bst
- components/gjs.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/geoclue.bst
