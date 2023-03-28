kind: meson

sources:
- kind: tar
  url: gnome_downloads:gtk-vnc/1.3/gtk-vnc-1.3.1.tar.xz
  ref: 512763ac4e0559d0158b6682ca5dd1a3bd633f082f5e4349d7158e6b5f80f1ce
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:components/gnutls.bst
- freedesktop-sdk.bst:components/perl-xml-parser.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gdk-pixbuf.bst
- components/glib.bst
- components/gtk+-3.bst
- freedesktop-sdk.bst:components/cyrus-sasl.bst
- freedesktop-sdk.bst:components/libpulse.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dintrospection=enabled
    -Dpulseaudio=enabled
    -Dsasl=enabled
    -Dwith-vala=enabled
