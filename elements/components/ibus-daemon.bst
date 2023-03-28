kind: filter

build-depends:
- components/ibus.bst

runtime-depends:
- components/dconf.bst
- components/glib.bst
- components/gtk+-3.bst
- components/libibus.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  exclude:
    - libibus
