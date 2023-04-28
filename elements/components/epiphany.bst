kind: meson

sources:
- kind: tar
  url: gnome_downloads:epiphany/44/epiphany-44.2.tar.xz
  ref: b1f6df15fb6a617fedd6198b2dcaabd4410d25834409da515709dd77cfc56b33
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
