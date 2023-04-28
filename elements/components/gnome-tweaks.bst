kind: meson

sources:
- kind: git_tag
  url: gnome:gnome-tweaks.git
  track: master

  ref: 42.beta-65-g47d8b817c46938732a66fa970f23eb6ed5b5c9f3
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/gnome-shell.bst
- components/nautilus.bst
- components/librsvg.bst
- components/pygobject.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
