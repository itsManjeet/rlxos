kind: meson

sources:
- kind: tar
  url: gnome_downloads:epiphany/43/epiphany-43.0.tar.xz
  ref: b66d499f9ee72696d83cf844125377181a954554a4bb3785b73293380ac0c227
build-depends:
- components/appstream-glib.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/libdazzle.bst
- components/libportal.bst
- components/adwaita-icon-theme.bst
- components/gcr-3.bst
- components/gdk-pixbuf.bst
- components/glib-networking.bst
- components/glib.bst
- components/gtk+-3.bst
- components/json-glib.bst
- components/libhandy.bst
- components/libsecret.bst
- components/libsoup.bst
- components/webkit2gtk-4.1.bst
- freedesktop-sdk.bst:components/iso-codes.bst
- freedesktop-sdk.bst:bootstrap-import.bst
