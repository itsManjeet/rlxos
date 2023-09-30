kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-music/45/gnome-music-45.0.tar.xz
  ref: 33e770166226a74537d4c10b1538efa8842494ffe9bf2c90a16cab98ab997bdf
build-depends:
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/grilo-plugins.bst
- components/grilo.bst
- components/libmediaart.bst
- components/tracker-miners.bst
- components/gvfs-daemon.bst
- components/adwaita-icon-theme.bst
- components/gtk.bst
- components/libadwaita.bst
- components/pygobject.bst
- components/tracker.bst
- freedesktop-sdk.bst:bootstrap-import.bst
