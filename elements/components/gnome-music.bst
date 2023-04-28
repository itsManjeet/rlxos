kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-music/44/gnome-music-44.0.tar.xz
  ref: 9bd1aac9572e62472024a6950d83ae6f286be33cd9c777f3d44fa16d038f1d51
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
