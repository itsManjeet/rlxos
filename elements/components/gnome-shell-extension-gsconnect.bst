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
  ref: v55-97-gf0777669c7b2dd9be89d4bf342edd23bfb06d281
