kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-online-accounts/3.48/gnome-online-accounts-3.48.0.tar.xz
  ref: 418bb9fcffdbd72a98205ad365137617fc1e3551a54de74f6a98d45d266175bf
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/librest.bst
- components/gcr-3.bst
- components/gtk+-3.bst
- components/json-glib.bst
- components/libsecret.bst
- components/libsoup.bst
- components/webkit2gtk-4.1.bst
- freedesktop-sdk.bst:bootstrap-import.bst
