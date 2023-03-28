kind: manual

build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  install-commands:
  - |
    mkdir %{install-root}/sys
    mkdir %{install-root}/dev
    mkdir %{install-root}/proc
    mkdir %{install-root}/tmp
