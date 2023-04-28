kind: meson
sources:
- kind: tar
  url: gnome_downloads:simple-scan/44/simple-scan-44.0.tar.xz
  ref: 39b870fd46f447f747eaecc2df26049ef773185099f0e13c675656264dd98e95
build-depends:
- components/vala.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/colord-gtk.bst
- components/libgusb.bst
- components/sane-backends.bst
- components/adwaita-icon-theme.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gtk+-3.bst
- components/libhandy.bst
- freedesktop-sdk.bst:bootstrap-import.bst
