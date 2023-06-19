kind: manual

config:
  install-commands:
  - |
    mkdir -p %{install-root}/sys
    mkdir -p %{install-root}/dev
    mkdir -p %{install-root}/proc
    mkdir -p %{install-root}/tmp
  

build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst