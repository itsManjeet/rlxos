kind: meson

sources:
- kind: tar
  url: gnome_downloads:nautilus/44/nautilus-44.1.tar.xz
  ref: 360802a595e3edbad962c8cea353b62baa8be407513b5162c89c933ca5387aa9
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
