kind: meson

sources:
- kind: git_tag
  url: gnome:gnome-tweaks.git
  track: master

  ref: 42.beta-29-g060bb924d087d96592ed565ddf8fc584d361aa90
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
