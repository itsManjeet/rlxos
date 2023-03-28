kind: meson
sources:
- kind: tar
  url: freedesktop:libfprint/libfprint/-/archive/v1.94.5/libfprint-v1.94.5.tar.gz
  ref: 111eb8d99a32b670a12647ee2d5303be335d11799f9dd420698953a35f73b96d
depends:
- components/glib.bst
- freedesktop-sdk.bst:components/libgusb.bst
- freedesktop-sdk.bst:components/pixman.bst
- freedesktop-sdk.bst:components/nss.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:components/libgudev.bst

build-depends:
- freedesktop-sdk.bst:components/gobject-introspection.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

variables:
  meson-local: >-
    -Ddoc=false
