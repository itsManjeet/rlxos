kind: meson

sources:
- kind: tar
  url: gnome_downloads:totem/43/totem-43.0.tar.xz
  ref: b36d3655928b5896462a4d39f83b6ad66d37dbc9c99dceb02ea8a2e37394a41e
build-depends:
- components/appstream-glib.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/grilo-plugins.bst
- components/grilo.bst
- components/libpeas.bst
- components/libportal.bst
- components/totem-pl-parser.bst
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- components/gst-plugins-bad.bst
- components/gst-plugins-base.bst
- components/gst-plugins-good.bst
- components/gtk+-3.bst
- components/libhandy.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:bootstrap-import.bst
