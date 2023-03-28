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
  ref: v44-29-g013fdcbbe47161bdfc018a6f6172f9096cf29ed9
