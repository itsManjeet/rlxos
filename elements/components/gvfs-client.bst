kind: filter

build-depends:
- components/gvfs.bst

runtime-depends:
- components/glib.bst
- freedesktop-sdk.bst:bootstrap-import.bst

config:
  include:
  - gvfs-client
  include-orphans: false
