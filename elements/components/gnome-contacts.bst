kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-contacts/44/gnome-contacts-44.0.tar.xz
  ref: 7dd1163bc1f06af6382dae4015c43443ee2c12928128fc99fd449292d0de7bed
build-depends:
- components/vala.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/folks.bst
- components/gnome-online-accounts.bst
- components/libportal.bst
- components/cheese.bst
- components/libqrencode.bst
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- components/libgee.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:bootstrap-import.bst
