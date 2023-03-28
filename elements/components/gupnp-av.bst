kind: meson

sources:
- kind: tar
  url: gnome_downloads:gupnp-av/0.14/gupnp-av-0.14.1.tar.xz
  ref: b79ce0cc4b0c66d9c54bc22183a10e5709a0011d2af272025948efcab33a3e4f
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gupnp.bst
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
