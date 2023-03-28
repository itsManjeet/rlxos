kind: meson

sources:
- kind: tar
  url: gnome_downloads:libsoup/2.74/libsoup-2.74.3.tar.xz
  ref: e4b77c41cfc4c8c5a035fcdc320c7bc6cfb75ef7c5a034153df1413fa1d92f13
build-depends:
- components/sysprof-minimal.bst
- components/gobject-introspection.bst
- components/gtk-doc.bst
- components/vala.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/glib-networking.bst

depends:
- components/glib.bst
- components/krb5.bst
- freedesktop-sdk.bst:components/brotli.bst
- freedesktop-sdk.bst:components/libpsl.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/sqlite.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  meson-local: >-
    -Dtls_check=false
    -Dgtk_doc=true
    -Dntlm=disabled
    -Dsysprof=enabled

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libsoup-2.4.so'
        - '%{libdir}/libsoup-gnome-2.4.so'
