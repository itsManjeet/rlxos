kind: meson

sources:
- kind: tar
  url: gnome_downloads:nautilus/45/nautilus-45.0.tar.xz
  ref: b311c465ce2ca7bc648f61b865187b4451388dec9358a169f3277e741718ab5d
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/tracker-miners.bst
- components/adwaita-icon-theme.bst

depends:
- components/gexiv2.bst
- components/gnome-autoar.bst
- components/libcloudproviders.bst
- components/libportal.bst
- components/gnome-desktop.bst
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- components/gtk.bst
- components/libadwaita.bst
- components/pango.bst
- components/tracker.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dselinux=false
