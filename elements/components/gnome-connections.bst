kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-connections/44/gnome-connections-44.1.tar.xz
  ref: 136a2d924b077d5cc4100c845826d471444230a16c8dac2732113680171a626b
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
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
