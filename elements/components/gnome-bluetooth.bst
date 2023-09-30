kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-bluetooth/42/gnome-bluetooth-42.6.tar.xz
  ref: 5864fe6f1e718715db26b62201b75a59020cf4247fec37645b3559cd2dba59d0
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gsound.bst
- components/upower.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- components/libnotify.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dgtk_doc=true
