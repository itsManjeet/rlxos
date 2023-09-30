kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-font-viewer/45/gnome-font-viewer-45.0.tar.xz
  ref: 97cb6b68dda60de0ab3038383586f1e4bc1da5a48f44025bd6bbe74ea05c2b08
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
