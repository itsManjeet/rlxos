kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-characters/45/gnome-characters-45.0.tar.xz
  ref: 3fd54fcc14d291b77fff12deefff00da383e0a6400af507d1605fbcb49b8c741
build-depends:
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/adwaita-icon-theme.bst
- components/gjs.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:bootstrap-import.bst
