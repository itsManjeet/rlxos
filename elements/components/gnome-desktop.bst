kind: meson

sources:
- kind: tar
  url: gnome_downloads:gnome-desktop/43/gnome-desktop-43.rc.tar.xz
  ref: 2a203d76e04f0ebba3dd17bf33474ac19fc4768b6e84fc9177132ed4ceca6ced
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- components/gtk+-3.bst
- components/gtk.bst
- freedesktop-sdk.bst:components/iso-codes.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/libseccomp.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dgtk_doc=true
    -Dinstalled_tests=true
