kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-photos/44/gnome-photos-44.0.tar.xz
  ref: e78e210397d3c62809c6cd5521da6eccb4a11ddea5bf2af8632a47f4da5c829e
build-depends:
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/tracker-miners.bst
- components/adwaita-icon-theme.bst

depends:
- components/babl.bst
- components/gegl.bst
- components/geocode-glib.bst
- components/gexiv2.bst
- components/gnome-online-accounts.bst
- components/libdazzle.bst
- components/libportal.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- components/gtk+-3.bst
- components/libhandy.bst
- components/tracker.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dinstalled_tests=false
    -Ddogtail=false
