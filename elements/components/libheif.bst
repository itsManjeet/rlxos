kind: cmake

sources:
- kind: tar
  url: github_files:strukturag/libheif/releases/download/v1.16.2/libheif-1.16.2.tar.gz
  ref: 7f97e4205c0bd9f9b8560536c8bd2e841d1c9a6d610401eb3eb87ed9cdfe78ea

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:components/dav1d.bst
