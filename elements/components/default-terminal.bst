kind: manual

build-depends:
- freedesktop-sdk.bst:bootstrap-import.bst

runtime-depends:
- components/gnome-console.bst

config:
  install-commands:
    - mkdir -p %{install-root}/usr/bin/
    - ln -sv kgx %{install-root}/usr/bin/gnome-terminal