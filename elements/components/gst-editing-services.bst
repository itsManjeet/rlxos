kind: meson

sources:
- kind: tar
  url: gstreamer:src/gstreamer-editing-services/gstreamer-editing-services-1.16.3.tar.xz

  ref: 9b05cbb8a6f1db53999e7ad11f00f4f1ccc154d6805b7e49cb7755eb37a99ba6
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gst-plugins-bad.bst
- components/gst-plugins-base.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:bootstrap-import.bst
