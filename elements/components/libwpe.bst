kind: cmake
sources:
- kind: tar
  url: wpewebkit:libwpe-1.14.1.tar.xz
  ref: b1d0cdcf0f8dbb494e65b0f7913e357106da9a0d57f4fbb7b9d1238a6dbe9ade
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
