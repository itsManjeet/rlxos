kind: manual

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/unzip.bst
- components/gnome-shell.bst

environment:
  UUID: blur-my-shell@aunetx
config:
  build-commands:
  - make build

  install-commands:
  - mkdir -p %{install-root}/usr/share/gnome-shell/extensions/${UUID}/
  - unzip build/${UUID}.shell-extension.zip -d %{install-root}/usr/share/gnome-shell/extensions/${UUID}/
sources:
- kind: git_tag
  url: github:aunetx/blur-my-shell.git
  track: master
  ref: v51-1-gc268a380e5c73f070dd32ecdc2de1b65bba81b42
