kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-clocks/44/gnome-clocks-44.0.tar.xz
  ref: 17d7a97365cb8f1a023a1d78f7501f3353217fa7577d73afe7d0ca1e3b4f3838
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
