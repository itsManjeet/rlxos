kind: meson

sources:
- kind: tar
  url: gnome_downloads:gupnp/1.6/gupnp-1.6.5.tar.xz
  ref: 437dff970142e8407087a89855f717e20d27c9d76e05b4cd517df621c7d888cd
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/networkmanager.bst
- components/gssdp.bst
- components/glib.bst
- components/libsoup.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dcontext_manager=network-manager
