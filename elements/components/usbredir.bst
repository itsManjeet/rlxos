kind: meson
sources:
- kind: tar
  url: spice:usbredir/usbredir-0.13.0.tar.xz
  ref: 4ba6faa02c0ae6deeb4c53883d66ab54b3a5899bead42ce4ded9568b9a7dc46e
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- components/spice-protocol.bst
depends:
- components/glib.bst
- freedesktop-sdk.bst:components/libusb.bst
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  meson-local: >-
    -Dgit_werror=disabled
    -Dfuzzing=disabled
