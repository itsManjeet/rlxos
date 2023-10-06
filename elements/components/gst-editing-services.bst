kind: meson

variables:
  meson-local: >-
    -Ddoc=disabled
    -Dbash-completion=disabled
    -Dxptv=disabled
    -Dpython=disabled
    -Dvalidate=disabled

sources:
- kind: tar
  url: gstreamer:src/gstreamer-editing-services/gst-editing-services-1.20.6.tar.xz
  ref: 150e6f2acafce96d9f363a4af4b034f2cd034cf41e03fccfcee50181648761bb
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:components/gstreamer-plugins-bad.bst
- freedesktop-sdk.bst:components/gstreamer-plugins-base.bst
- freedesktop-sdk.bst:bootstrap-import.bst
