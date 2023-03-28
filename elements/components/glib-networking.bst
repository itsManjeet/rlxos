kind: meson
sources:
- kind: tar
  url: gnome_downloads:glib-networking/2.74/glib-networking-2.74.0.tar.xz
  ref: 1f185aaef094123f8e25d8fa55661b3fd71020163a0174adb35a37685cda613b
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
