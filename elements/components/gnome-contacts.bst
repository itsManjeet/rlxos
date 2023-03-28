kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-contacts/43/gnome-contacts-43.0.tar.xz
  ref: 55b61df7e93f0abe1ffa465e18e3c5de4f49a90f268ea9d11edc86af06d071e1
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
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- components/libgee.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:bootstrap-import.bst
