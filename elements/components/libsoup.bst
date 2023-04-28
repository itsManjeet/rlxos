kind: meson

sources:
- kind: tar
  url: gnome_downloads:libsoup/3.4/libsoup-3.4.1.tar.xz
  ref: 530b867b1b166cb9bca2750f1d15e5187318b5d948efb81d5899af3d75614504
build-depends:
- components/gi-docgen.bst
- components/gobject-introspection.bst
- components/sysprof-minimal.bst
- components/vala.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/glib-networking.bst

depends:
- components/glib.bst
- components/krb5.bst
- freedesktop-sdk.bst:components/brotli.bst
- freedesktop-sdk.bst:components/gnutls.bst
- freedesktop-sdk.bst:components/libnghttp2.bst
- freedesktop-sdk.bst:components/libpsl.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/sqlite.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dautobahn=disabled
    -Dinstalled_tests=true
    -Dntlm=disabled
    -Dsysprof=enabled
    -Dtls_check=false

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libsoup-3.0.so'
