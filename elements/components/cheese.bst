kind: meson

sources:
- kind: tar
  url: gnome_downloads:cheese/44/cheese-44.0.1.tar.xz
  ref: d922401272cdd415c292703e52c6b364466a0b20ee1db320251644c283606fd4
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/clutter-gst.bst
- components/clutter-gtk.bst
- components/gnome-video-effects.bst
- components/libcanberra.bst
- components/gnome-desktop.bst
- components/adwaita-icon-theme.bst
- components/glib.bst
- components/gst-plugins-bad.bst
- components/gst-plugins-base.bst
- components/gst-plugins-good.bst
- components/gtk+-3.bst
- components/librsvg.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:bootstrap-import.bst
