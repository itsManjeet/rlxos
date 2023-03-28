kind: cmake

sources:
- kind: tar
  url: github_files:LibVNC/libvncserver/archive/LibVNCServer-0.9.13.tar.gz

  ref: 0ae5bb9175dc0a602fe85c1cf591ac47ee5247b87f2bf164c16b05f87cbfa81a
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
