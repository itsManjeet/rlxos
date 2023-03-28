kind: cmake
sources:
- kind: tar
  url: github_files:Exiv2/exiv2/archive/v0.27.3.tar.gz
  ref: 6398bc743c32b85b2cb2a604273b8c90aa4eb0fd7c1700bf66cbb2712b4f00c1
- kind: patch
  path: patches/exiv2/disable-protection-flags.patch
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
