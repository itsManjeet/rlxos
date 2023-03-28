kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-photos/43/gnome-photos-43.0.tar.xz
  ref: c7ac7458d533f29d955011c74b76224d79ea31bcc12e9d6d0ce7b6c3704d08e1
build-depends:
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/tracker-miners.bst
- components/grilo-plugins.bst
- components/adwaita-icon-theme.bst

depends:
- components/babl.bst
- components/gegl.bst
- components/geocode-glib.bst
- components/gexiv2.bst
- components/gnome-online-accounts.bst
- components/grilo.bst
- components/libdazzle.bst
- components/libgdata.bst
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
