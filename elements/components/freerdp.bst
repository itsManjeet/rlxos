kind: cmake

sources:
- kind: tar
  url: freerdp:releases/freerdp-2.10.0.tar.gz

  ref: a673d3fc21911dd9f196834f2f3a23c3ebc7e5e4deab2f7686fcec879279e2c1
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
