kind: meson

sources:
- kind: tar
  url: freedesktop_files:geoclue/geoclue/-/archive/2.7.0/geoclue-2.7.0.tar.gz

  ref: 761931226a7b8ecf3098c9ee1ff1240adec2870a6d9129ad89e934d3aa761be5
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/json-glib.bst
- components/libnotify.bst
- components/libsoup-2.4.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -D3g-source=false
    -Dcdma-source=false
    -Dmodem-gps-source=false
    -Dnmea-source=false

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgeoclue-2.so'
