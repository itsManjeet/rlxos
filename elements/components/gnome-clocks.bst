kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-clocks/43/gnome-clocks-43.0.tar.xz
  ref: b0743b70d00880aa3bcdcc7f7f34c8c2286257b5c81737d4f981bc8c4f4f981d
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
- components/geoclue.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
