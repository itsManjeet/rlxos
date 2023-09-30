kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-clocks/45/gnome-clocks-45.0.tar.xz
  ref: fc8eb4fd9530f1e641dc00ee2086ee7d354a7a00b0a0d1722e305d5c9aab91b5
build-depends:
- components/vala.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/geocode-glib.bst
- components/gsound.bst
- components/libgweather.bst
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/geoclue.bst
