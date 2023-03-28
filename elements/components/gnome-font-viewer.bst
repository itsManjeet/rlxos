kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-font-viewer/43/gnome-font-viewer-43.0.tar.xz
  ref: 81c6bffb06d5332346e00eaecaec1bdcfd617c51dfd95bcd058d6c76c76dd2b9
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
