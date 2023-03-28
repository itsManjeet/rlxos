kind: autotools
sources:
- kind: tar
  url: github_files:gphoto/libgphoto2/releases/download/v2.5.27/libgphoto2-2.5.27.tar.xz
  ref: a7253bd18c6ef65352150ac36a668f883a5ad2634eb6455b3ca9aa6ac98d0073
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:bootstrap-import.bst
