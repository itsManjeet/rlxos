kind: meson
sources:
- kind: tar
  url: gnome_downloads:simple-scan/42/simple-scan-42.5.tar.xz
  ref: 05f5dfa4e9e206efa9d404c9861dd7c442091793e734c41719739917250e4050
build-depends:
- components/vala.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/colord-gtk.bst
- components/libgusb.bst
- components/sane-backends.bst
- components/adwaita-icon-theme.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gtk+-3.bst
- components/libhandy.bst
- freedesktop-sdk.bst:bootstrap-import.bst
