kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-boxes/43/gnome-boxes-43.2.tar.xz
  ref: 9c3e0e9433c1853a99ed52edec13263f443f856dbca3b2165c2e3a70b8632b30
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
- components/tracker-miners.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk+-3.bst
- components/gtksourceview-4.bst
- components/json-glib.bst
- components/libhandy.bst
- components/libsecret.bst
- components/tracker.bst
- components/webkit2gtk-4.1.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:bootstrap-import.bst
