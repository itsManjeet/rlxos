kind: meson

sources:
- kind: tar
  url: gnome_downloads:gupnp/1.6/gupnp-1.6.3.tar.xz
  ref: 4f4f418b07b81164df1f7ab612e28e4c016c2d085b8a4f39f97945f8b15ee248
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
