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
  ref: v54-25-g2039513393da9279206c874abdda16ced427532e
