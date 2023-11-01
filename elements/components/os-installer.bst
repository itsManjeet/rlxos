kind: manual

sources:
- kind: git_tag
  url: github:itsmanjeet/os-installer.git
  track: main

  ref: deaf530d1c1fb33e244149208336eddf422b0bc2
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

config:
  install-commands:
  - mkdir -p %{install-root}/%{prefix}
  - cp -r bin share %{install-root}/%{prefix}/
