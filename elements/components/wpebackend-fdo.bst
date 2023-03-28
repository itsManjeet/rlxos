kind: meson
sources:
- kind: tar
  url: wpewebkit:wpebackend-fdo-1.14.0.tar.xz
  ref: e75b0cb2c7145448416e8696013d8883f675c66c11ed750e06865efec5809155
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/libwpe.bst
- freedesktop-sdk.bst:components/libepoxy.bst
- freedesktop-sdk.bst:components/mesa-headers.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:bootstrap-import.bst
