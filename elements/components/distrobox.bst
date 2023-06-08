kind: manual

sources:
- kind: git_tag
  url: github:89luca89/distrobox
  track: main
  ref: 1.4.2.1-111-gf008b521ee776a66c36a87848c85d3e3f0f6a3dd
build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst

runtime-depends:
- components/podman.bst

config:
  install-commands:
  - ./install -P %{install-root}/usr
