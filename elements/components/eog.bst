kind: meson

sources:
- kind: tar
  url: gnome_downloads:eog/44/eog-44.1.tar.xz
  ref: e2c963f232fe5a1091dcc18bec25a730e91b02af6e466601efa55e500cd74cab
build-depends:
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/exempi.bst
- components/libpeas.bst
- components/libportal.bst
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gobject-introspection.bst
- components/gsettings-desktop-schemas.bst
- components/gtk+-3.bst
- components/libhandy.bst
- components/librsvg.bst
- freedesktop-sdk.bst:components/lcms.bst
- freedesktop-sdk.bst:components/libexif.bst
- freedesktop-sdk.bst:bootstrap-import.bst

runtime-depends:
- components/webp-pixbuf-loader.bst
