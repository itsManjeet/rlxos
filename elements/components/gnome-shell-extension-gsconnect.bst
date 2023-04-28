kind: meson

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- components/gnome-shell.bst

variables:
  meson-local: >-
    -Dinstalled_tests=false

sources:
- kind: git_tag
  url: github:GSConnect/gnome-shell-extension-gsconnect.git
  track: main
  ref: v55-36-g182fbe98b3aa6072d8cd6282faacb2d875cdb522
