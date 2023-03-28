kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-connections/43/gnome-connections-43.0.tar.xz
  ref: 85dad82f93c0b2f609fe8ec7ecdeec70600a55612afc0e3f02774c25a0bb309f
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/freerdp.bst
- components/gtk-vnc.bst
- components/adwaita-icon-theme.bst
- components/gtk+-3.bst
- components/libhandy.bst
- components/libsecret.bst
- freedesktop-sdk.bst:bootstrap-import.bst
