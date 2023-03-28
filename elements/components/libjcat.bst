kind: meson

sources:
- kind: tar
  url: github_files:hughsie/libjcat/archive/0.1.6.tar.gz

  ref: 8de77399dd3f7cd055f07003e6fce438ef8339e2bfd90c29982b7ee0a2e72884
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:components/help2man.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/libgusb.bst
- components/glib.bst
- components/json-glib.bst
- freedesktop-sdk.bst:components/gnutls.bst
- freedesktop-sdk.bst:components/gpgme.bst
