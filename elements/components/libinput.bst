kind: meson
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/doxygen.bst

depends:
- freedesktop-sdk.bst:components/jpeg.bst
- freedesktop-sdk.bst:components/libpng.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:components/mtdev.bst
- freedesktop-sdk.bst:components/libevdev.bst
- freedesktop-sdk.bst:components/libwacom.bst

variables:
  meson-local: >-
    -Ddebug-gui=false
    -Ddocumentation=false
    -Dtests=false
    -Dzshcompletiondir=no
sources:
- kind: tar
  url: freedesktop_software:libinput/libinput-1.19.4.tar.xz
  ref: ff33a570b5a936c81e6c08389a8581c2665311d026ce3d225c88d09c49f9b440
