kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-contacts/45/gnome-contacts-45.beta.tar.xz
  ref: d1b60f77778d1579ee1ee4835fe15a4d8243f5123d856ea10eb00d77029b2e39
build-depends:
- components/vala.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/folks.bst
- components/gnome-online-accounts.bst
- components/libportal.bst
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- components/libgee.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/libqrencode.bst
- freedesktop-sdk.bst:bootstrap-import.bst
