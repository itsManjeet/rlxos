kind: cmake

sources:
- kind: tar
  url: github_files:google/highway/archive/refs/tags/1.0.5.tar.gz
  ref: 99b7dad98b8fa088673b720151458fae698ae5df9154016e39de4afdc23bb927

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst

variables:
  cmake-local: >-
    -DBUILD_TESTING=OFF
