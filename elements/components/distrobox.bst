kind: manual

sources:
- kind: git_tag
  url: github:89luca89/distrobox
  track: main
  ref: 1.4.2.1-94-g5c780e2773149ef9ea0b2e314853dfb0fc631a62
build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst

runtime-depends:
- components/podman.bst

config:
  install-commands:
  - ./install -P %{install-root}/usr
