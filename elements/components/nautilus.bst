kind: meson

sources:
- kind: tar
  url: gnome_downloads:nautilus/43/nautilus-43.2.tar.xz
  ref: a86a9aa7a455511b029ce49a1d8b4659c3c355b5d81d7360bb4d0de637afede0
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
