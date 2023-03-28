kind: meson
sources:
- kind: tar
  url: gnome_downloads:gnome-maps/43/gnome-maps-43.3.tar.xz
  ref: 89551e94b1271305cfff204b44c18367267781a57d2ccb7b6f7bba628e09c511
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
runtime-depends:
- components/adwaita-icon-theme.bst
- components/glib-networking.bst
- components/librsvg.bst
depends:
- components/libshumate.bst
- components/libgweather.bst
- components/librest.bst
- components/geoclue.bst
- components/gjs.bst
- components/glib.bst
- components/gobject-introspection.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:bootstrap-import.bst
