kind: cmake
sources:
- kind: tar
  url: wpewebkit:libwpe-1.15.1.tar.xz
  ref: 14d36a93a05ab7ada9bec581720b8057336fe681bbbe59bda7d50cb8f3eba3a6
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
