kind: meson

sources:
- kind: git_tag
  url: github:itsmanjeet/os-installer.git
  track: main
  submodules:
    subprojects/blueprint-compiler:
      checkout: true
      url: https://gitlab.gnome.org/jwestman/blueprint-compiler.git


  ref: 0.2-204-gbdd275296617f2ec876880aedba3212b15679918

- kind: patch
  path: patches/os-installer/no-flat-header.patch

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/gnupg.bst
- components/udisks2.bst
- components/gnome-desktop.bst
- components/glib-networking.bst
- components/glib.bst
- components/gtk+-3.bst
- components/libadwaita.bst
- components/pygobject.bst
- freedesktop-sdk.bst:components/python3-pyyaml.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/git.bst
- components/intltool.bst

runtime-depends:
- components/gnome-session.bst
