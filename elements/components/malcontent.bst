kind: meson

sources:
- kind: tar
  url: freedesktop_files:pwithnall/malcontent/-/archive/0.11.0/malcontent-0.11.0.tar.gz

  ref: e6b94831afe255818a881813ed161bd75e713cca0a052d909ec7e683f0e76960
build-depends:
- components/glib-testing.bst
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/appstream.bst
- components/accountsservice.bst
- components/flatpak.bst
- components/glib.bst
- components/gtk.bst
- components/libadwaita.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst

runtime-depends:
- components/pygobject.bst
