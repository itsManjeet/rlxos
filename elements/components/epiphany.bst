kind: meson

sources:
- kind: tar
  url: gnome_downloads:epiphany/45/epiphany-45.0.tar.xz
  ref: 0ba2443a3390d75d63271e30b9aa1c7b8f37c1bba37bd346a7fdd20bbdb34791
build-depends:
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/libportal.bst
- components/adwaita-icon-theme.bst
- components/gcr.bst
- components/gdk-pixbuf.bst
- components/glib-networking.bst
- components/glib.bst
- components/gtk.bst
- components/json-glib.bst
- components/libadwaita.bst
- components/libsecret.bst
- components/libsoup.bst
- components/webkitgtk-6.0.bst
- freedesktop-sdk.bst:components/iso-codes.bst
- freedesktop-sdk.bst:components/libarchive.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dgranite=disabled
