kind: meson

sources:
- kind: tar
  url: gnome_downloads:xdg-desktop-portal-gnome/45/xdg-desktop-portal-gnome-45.0.tar.xz
  ref: 949598861c80000febf18cc12b3721c95c1bb1d19371fc2156dc4f33def5aff0
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gnome-desktop.bst
- components/gsettings-desktop-schemas.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/xdg-desktop-portal.bst
