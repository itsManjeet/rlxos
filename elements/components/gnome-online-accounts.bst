kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-online-accounts/3.46/gnome-online-accounts-3.46.0.tar.xz
  ref: 5e7859ce4858a6b99d3995ed70527d66e297bb90bbf75ec8780fe9da22c1fcaa
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
