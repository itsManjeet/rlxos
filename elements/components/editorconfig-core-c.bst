kind: cmake

sources:
- kind: tar
  url: github_files:editorconfig/editorconfig-core-c/archive/refs/tags/v0.12.5.tar.gz

  ref: b2b212e52e7ea6245e21eaf818ee458ba1c16117811a41e4998f3f2a1df298d2
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
