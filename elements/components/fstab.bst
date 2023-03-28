kind: manual

sources:
  - kind: local
    path: files/fstab

build-depends:
  - freedesktop-sdk.bst:components/systemd.bst
  - freedesktop-sdk.bst:components/m4.bst
  - freedesktop-sdk.bst:components/pkg-config.bst

config:
  install-commands:
    - install -Dm644 -t %{install-root}%{sysconfdir} fstab