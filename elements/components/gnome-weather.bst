kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-weather/43/gnome-weather-43.0.tar.xz
  ref: 2f11117f75552bf1bb9e01f01cfb3c2fcda6a3f69070ffe0519a0761532b8f26
build-depends:
- components/appstream-glib.bst
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
