kind: meson

sources:
- kind: tar
  url: gnome_downloads:libnma/1.10/libnma-1.10.6.tar.xz
  ref: 53a6fb2b190ad37c5986caed3e98bede7c3c602399ee4f93c8fc054303d76dab
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/networkmanager.bst
- components/mobile-broadband-provider-info.bst
- components/adwaita-icon-theme.bst
- components/gcr-3.bst
- components/glib.bst
- components/gtk+-3.bst
- components/gtk.bst
- freedesktop-sdk.bst:components/iso-codes.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dlibnma_gtk4=true
