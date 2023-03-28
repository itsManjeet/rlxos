kind: meson

sources:
- kind: tar
  url: freedesktop_software:appstream/releases/AppStream-0.15.4.tar.xz

  ref: c4126b6ebc889afb2e3ab5dfd8303bd31a9cd2a3992391de4dc66cb0e12846dd
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
