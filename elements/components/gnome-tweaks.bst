kind: meson

sources:
- kind: git_tag
  url: gnome:gnome-tweaks.git
  track: master

  ref: 42.beta-74-g8ef4ef3c9f9dff77928906b722269c5c05ee11f4
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- components/gnome-shell.bst
- components/nautilus.bst
- components/librsvg.bst
- components/pygobject.bst

depends:
- components/libhandy.bst
- freedesktop-sdk.bst:bootstrap-import.bst
