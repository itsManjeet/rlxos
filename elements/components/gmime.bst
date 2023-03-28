kind: autotools
sources:
- kind: tar
  url: gnome_downloads:gmime/3.2/gmime-3.2.7.tar.xz
  ref: 2aea96647a468ba2160a64e17c6dc6afe674ed9ac86070624a3f584c10737d44
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
