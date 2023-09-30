kind: meson
sources:
- kind: tar
  url: gnome_downloads:gobject-introspection/1.78/gobject-introspection-1.78.1.tar.xz
  ref: bd7babd99af7258e76819e45ba4a6bc399608fe762d83fde3cac033c50841bb4
build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/python3-mako.bst
- freedesktop-sdk.bst:components/python3-markdown.bst
variables:
  meson-local: >-
    -Dgtk_doc=true
    -Dcairo=disabled
    -Ddoctool=enabled
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{datadir}/gobject-introspection-1.0'
        - '%{datadir}/gobject-introspection-1.0/**'
        - '%{libdir}/libgirepository-1.0.so'
