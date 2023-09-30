kind: meson
sources:
- kind: tar
  url: gnome_downloads:glib-networking/2.78/glib-networking-2.78.0.tar.xz
  ref: 52fe4ce93f7dc51334b102894599858d23c8a65ac4a1110b30920565d68d3aba
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
