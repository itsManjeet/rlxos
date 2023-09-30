kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-connections/45/gnome-connections-45.0.tar.xz
  ref: b9fab525b90a3e27d113c16fb868c2b9c47bf8149310d14db862ea1912c06fb8
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
- freedesktop-sdk.bst:components/fuse3.bst
- freedesktop-sdk.bst:bootstrap-import.bst
