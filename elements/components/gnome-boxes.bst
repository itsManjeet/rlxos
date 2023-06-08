kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-boxes/44/gnome-boxes-44.2.tar.xz
  ref: 9dd389c149d0c0fa57456ec363d51a88255f945558fb9df42894ce78ef85df89
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
