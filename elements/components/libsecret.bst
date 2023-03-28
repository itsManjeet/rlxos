kind: meson

sources:
- kind: tar
  url: gnome_downloads:libsecret/0.20/libsecret-0.20.5.tar.xz
  ref: 3fb3ce340fcd7db54d87c893e69bfc2b1f6e4d4b279065ffe66dac9f0fd12b4d
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/vala.bst
- freedesktop-sdk.bst:components/valgrind-maybe.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- freedesktop-sdk.bst:components/libgcrypt.bst
- freedesktop-sdk.bst:bootstrap-import.bst

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libsecret-1.so'
