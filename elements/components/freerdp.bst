kind: cmake

sources:
- kind: tar
  url: freerdp:releases/freerdp-2.9.0.tar.gz

  ref: fcf71cf5b09c5c2636341ba212f34b8fb728246ea28e08caf6cef8b4a96184b7
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:components/cups.bst
- freedesktop-sdk.bst:components/ffmpeg.bst
- freedesktop-sdk.bst:components/libpulse.bst
- freedesktop-sdk.bst:components/libusb.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  cmake-local: >-
    -DWITH_SERVER=ON
    -DWITH_CHANNELS=ON
    -DWITH_SERVER_CHANNELS=ON
    -DWITH_CLIENT_CHANNELS=ON
    -DWITH_ALSA=OFF
    -DWITH_PCSC=OFF
    -DWITH_X11=OFF
