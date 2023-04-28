kind: meson
sources:
- kind: tar
  url: wpewebkit:wpebackend-fdo-1.14.2.tar.xz
  ref: 93c9766ae9864eeaeaee2b0a74f22cbca08df42c1a1bdb55b086f2528e380d38
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- components/glib.bst
- components/libwpe.bst
- freedesktop-sdk.bst:components/libepoxy.bst
- freedesktop-sdk.bst:components/mesa-headers.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:bootstrap-import.bst
