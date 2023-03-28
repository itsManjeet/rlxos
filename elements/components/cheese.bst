kind: meson

sources:
- kind: tar
  url: gnome_downloads:cheese/43/cheese-43.0.tar.xz
  ref: 74574c4a3c327327f1a2d6d0b3f937be2afb07a6159b6d78db9c192de6667f0b
build-depends:
- components/appstream-glib.bst
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
