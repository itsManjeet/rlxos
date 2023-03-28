kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-color-manager/3.36/gnome-color-manager-3.36.0.tar.xz
  ref: 9ddb9e6b6472e119801381f90905332ec1d4258981721bba831ca246ceb3ad3b
build-depends:
- components/appstream-glib.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/colord-gtk.bst
- components/exiv2.bst
- components/libcanberra.bst
- components/vte.bst
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:components/libexif.bst
- freedesktop-sdk.bst:bootstrap-import.bst
