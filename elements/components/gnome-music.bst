kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-music/42/gnome-music-42.1.tar.xz
  ref: c7747fa6a86b56b18ad6ff950ff901e59ee7fac11c68b2a6727af86eaeed8270
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
