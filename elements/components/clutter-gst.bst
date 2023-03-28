kind: autotools
sources:
- kind: tar
  url: gnome_downloads:clutter-gst/3.0/clutter-gst-3.0.27.tar.xz
  ref: fe69bd6c659d24ab30da3f091eb91cd1970026d431179b0724f13791e8ad9f9d
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- components/clutter.bst
- components/cogl.bst
- components/gdk-pixbuf.bst
- components/gst-plugins-base.bst
- freedesktop-sdk.bst:components/gstreamer.bst
- freedesktop-sdk.bst:bootstrap-import.bst
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libclutter-gst-3.0.so'
