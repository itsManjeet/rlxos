kind: cmake
sources:
- kind: tar
  url: wpewebkit:libwpe-1.14.0.tar.xz
  ref: c073305bbac5f4402cc1c8a4753bfa3d63a408901f86182051eaa5a75dd89c00
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:components/libxkbcommon.bst
- freedesktop-sdk.bst:components/mesa-headers.bst
- freedesktop-sdk.bst:bootstrap-import.bst

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libwpe-1.0.so'
