kind: manual

sources:
- kind: git_tag
  url: github:89luca89/distrobox
  track: main
  ref: 1.4.2.1-3-g5390c232192a36ac64d32e6f83c6d2056a929a18
build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst

runtime-depends:
- components/podman.bst

config:
  install-commands:
  - ./install -P %{install-root}/usr
