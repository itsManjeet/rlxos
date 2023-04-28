kind: meson

sources:
- kind: tar
  url: gimp:gegl/0.4/gegl-0.4.44.tar.xz

  ref: 0a4cdb41635e406a0849cd0d3f03caf7d97cab8aa13d28707d532d0089d56126
build-depends:
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/libraw.bst
- components/babl.bst
- components/gexiv2.bst
- components/graphviz.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/json-glib.bst
- components/librsvg.bst
- components/pango.bst
- freedesktop-sdk.bst:components/libtiff.bst
- freedesktop-sdk.bst:components/libwebp.bst
- freedesktop-sdk.bst:components/poppler.bst
- freedesktop-sdk.bst:components/sdl2.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Djasper=disabled
    -Dlensfun=disabled
    -Dlibav=disabled
    -Dlibspiro=disabled
    -Dlibv4l=disabled
    -Dlibv4l2=disabled
    -Dlua=disabled
    -Dmaxflow=disabled
    -Dmrg=disabled
    -Dopenexr=disabled
    -Dpygobject=disabled
    -Dumfpack=disabled
