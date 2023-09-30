kind: meson
sources:
- kind: tar
  url: gnome_downloads:gcab/1.6/gcab-1.6.tar.xz
  ref: 2f0c9615577c4126909e251f9de0626c3ee7a152376c15b5544df10fc87e560b
- kind: patch
  path: patches/gcab/ad0baea50359c1978a9224ee60bf98d97bfb991f.patch
build-depends:
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libgcab-1.0.so'
