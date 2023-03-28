kind: meson

sources:
- kind: tar
  url: freedesktop_people:~hughsient/appstream-glib/releases/appstream-glib-0.8.2.tar.xz

  ref: 71256500add5048d6f08878904708b3d0c3875f402e0adcd358e91d47dcd8b96
build-depends:
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/gperf.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/gcab.bst
- components/gdk-pixbuf.bst
- components/glib.bst
- components/json-glib.bst
- freedesktop-sdk.bst:components/curl.bst
- freedesktop-sdk.bst:components/libarchive.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dstemmer=false
    -Drpm=false
    -Dfonts=false
    -Ddep11=false

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libappstream-glib.so'
