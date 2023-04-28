kind: meson

sources:
- kind: tar
  url: spice:gtk/spice-gtk-0.42.tar.xz

  ref: 9380117f1811ad1faa1812cb6602479b6290d4a0d8cc442d44427f7f6c0e7a58
build-depends:
- components/python-pyparsing.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/perl.bst
- freedesktop-sdk.bst:components/python3-six.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/phodav.bst
- components/spice-protocol.bst
- components/usbredir.bst
- components/glib.bst
- components/gst-plugins-base.bst
- components/gtk+-3.bst
- components/json-glib.bst
- components/libsoup.bst
- components/vala.bst
- freedesktop-sdk.bst:components/cyrus-sasl.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/libcap-ng.bst
- freedesktop-sdk.bst:components/libdrm.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dsmartcard=disabled
