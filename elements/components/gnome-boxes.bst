kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-boxes/44/gnome-boxes-44.1.tar.xz
  ref: 3897060d696f7fa2d912e772c2761dbe53433ab5f19ebfa4bc4e897385faba53
build-depends:
- components/vala.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/libosinfo.bst
- components/libvirt-glib.bst
- components/osinfo-db.bst
- components/spice-gtk.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk+-3.bst
- components/gtksourceview-4.bst
- components/json-glib.bst
- components/libhandy.bst
- components/webkit2gtk-4.1.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:bootstrap-import.bst
