kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-font-viewer/44/gnome-font-viewer-44.0.tar.xz
  ref: a1511df30b228cc2ef1175dd9d2b93438ea912e25913404b263cf3d457bb9f97
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
