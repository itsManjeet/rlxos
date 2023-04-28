kind: cmake

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- components/gdk-pixbuf.bst
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/aom.bst
- freedesktop-sdk.bst:components/dav1d.bst

sources:
- kind: tar
  url: github_files:AOMediaCodec/libavif/archive/refs/tags/v0.11.1.tar.gz
  ref: 0eb49965562a0e5e5de58389650d434cff32af84c34185b6c9b7b2fccae06d4e
variables:
  cmake-local: >-
    -DAVIF_BUILD_GDK_PIXBUF=ON
    -DAVIF_CODEC_AOM=ON
    -DAVIF_CODEC_DAV1D=ON

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libavif.so'
