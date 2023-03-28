kind: meson

sources:
- kind: tar
  url: freedesktop:upower/upower/-/archive/v0.99.14/upower-v0.99.14.tar.bz2

  ref: 8997593ab66cc77787d68c6e1c8aec2d6bcde752336bdad9079ed3ed7631fe07
build-depends:
- components/gtk-doc.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/libimobiledevice.bst
- components/gobject-introspection.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/libusb.bst
- freedesktop-sdk.bst:bootstrap-import.bst
