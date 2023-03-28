kind: autotools

sources:
- kind: tar
  url: gitlab:graphviz/graphviz/-/archive/2.47.1/graphviz-2.47.1.tar.gz

  ref: b7f4d6819e4dc17c15e7e07bd1ea5e081ef6569b63f8427117dac32f0e3837b4
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- components/gdk-pixbuf.bst
- components/glib.bst
- components/pango.bst
- freedesktop-sdk.bst:components/cairo.bst
- freedesktop-sdk.bst:components/dejavu-fonts.bst
- freedesktop-sdk.bst:components/expat.bst
- freedesktop-sdk.bst:components/fontconfig.bst
- freedesktop-sdk.bst:components/freetype.bst
- freedesktop-sdk.bst:components/jpeg.bst
- freedesktop-sdk.bst:components/libpng.bst
- freedesktop-sdk.bst:components/libtool.bst

variables:
  conf-local: >-
    --disable-dependency-tracking
    --disable-silent-rules
    --disable-sharp
    --disable-ocaml
    --disable-r
    --without-lasi
    --without-gts
    --without-ming
    --without-devil
    --without-qt
    --with-pangocairo
    --with-gdk-pixbuf

public:
  bst:
    integration-commands:
    - dot -c
