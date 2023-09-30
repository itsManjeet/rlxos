kind: manual

sources:
- kind: git_tag
  url: github:89luca89/distrobox
  track: main
  ref: 1.5.0.2-188-g9309e1ebe5c70fd1f9b5286fd3a76f3e7bd995bd
build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst

runtime-depends:
- components/podman.bst

config:
  install-commands:
  - ./install -P %{install-root}/usr
