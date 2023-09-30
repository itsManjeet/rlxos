kind: meson

sources:
- kind: git_tag
  url: gnome:gnome-tweaks.git
  track: master

  ref: 45.0-8-g4ef70e6bd9103ecc7d97889c6685bf44bf99ef80
# - kind: patch
#   path: patches/gnome-tweaks/0001-rlxos-support-libadwaita-theme-switcher.patch
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
