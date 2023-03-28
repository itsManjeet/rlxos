kind: cmake
sources:
- kind: tar
  url: github_files:lipnitsk/libcue/archive/v2.2.1.tar.gz
  ref: f27bc3ebb2e892cd9d32a7bee6d84576a60f955f29f748b9b487b173712f1200
build-depends:
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
variables:
  cmake-local: >-
    -DBUILD_SHARED_LIBS=ON
