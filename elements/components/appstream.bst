kind: meson

sources:
- kind: tar
  url: freedesktop_software:appstream/releases/AppStream-0.15.5.tar.xz

  ref: cb15ed62cc2729683879a2dbf98c0a3267ea2b4d57bba6bc55e70a25500e04c2
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/curl.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/gperf.bst
- freedesktop-sdk.bst:components/itstool.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/lmdb.bst
- components/xmlb.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/librsvg.bst
- freedesktop-sdk.bst:components/cairo.bst
- freedesktop-sdk.bst:components/curl.bst
- freedesktop-sdk.bst:components/libarchive.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/libyaml.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dcompose=true
    -Dapidocs=false
    -Dinstall-docs=false
    -Dstemming=false

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libappstream.so'
