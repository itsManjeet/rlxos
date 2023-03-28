kind: meson
sources:
- kind: tar
  url: freedesktop_files:spice/libcacard/uploads/9d8f24b131bcbbd7846727ea92952cb5/libcacard-2.8.0.tar.xz
  ref: 8005b93c3139ff739057efb19f9dac1d0993ffb0b913111505af6a91711ef22b
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:components/nss.bst
- freedesktop-sdk.bst:components/pcsc-lite.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Ddisable_tests=true
