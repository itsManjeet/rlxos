kind: meson

sources:
- kind: tar
  url: gnome_downloads:nautilus/44/nautilus-44.2.tar.xz
  ref: 274a065927596d8a8f09537adc91bae98297201dd47ec6ccd878111e0781d3e5
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
