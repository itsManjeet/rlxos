kind: cmake
sources:
- kind: tar
  url: github_files:nuspell/nuspell/archive/refs/tags/v5.0.1.tar.gz
  ref: a48d9b0297f9c87d8e3231b2662786c5380634cd2b2e0005c55709caefdaa032
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
depends:
- freedesktop-sdk.bst:components/hunspell.bst
- freedesktop-sdk.bst:components/icu.bst
- freedesktop-sdk.bst:bootstrap-import.bst
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libnuspell.so'
