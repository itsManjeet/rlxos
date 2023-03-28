kind: manual

depends:
  - freedesktop-sdk.bst:bootstrap-import.bst
  - freedesktop-sdk.bst:components/sudo.bst

config:
  install-commands:
    - install -Dm644 -t "%{install-root}%{sysconfdir}/sudoers.d" wheel

sources:
  - kind: local
    path: files/sudo