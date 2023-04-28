kind: meson
sources:
- kind: tar
  url: gnome_downloads:glib-networking/2.76/glib-networking-2.76.0.tar.xz
  ref: 149a05a179e629a538be25662aa324b499d7c4549c5151db5373e780a1bf1b9a
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- components/gsettings-desktop-schemas.bst
- freedesktop-sdk.bst:components/ca-certificates.bst
- freedesktop-sdk.bst:components/gnutls.bst
- freedesktop-sdk.bst:components/libproxy.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dinstalled_tests=true
