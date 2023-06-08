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
  ref: v55-40-g370493b76ab4ee7f30ba154b1e5b554a02413703
