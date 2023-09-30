kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-boxes/45/gnome-boxes-45.0.tar.xz
  ref: cc63080eefa147a8472ab1a5ff087b97a27ab723a4ee005ed41e8c9dd7798e41
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
- components/json-glib.bst
- components/libhandy.bst
- components/webkit2gtk-4.1.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:bootstrap-import.bst
