kind: ostree

config:
  environment:
  - components/libostree.bst

  ostree-branch: "%{extension-prefix}/devel"

build-depends:
- components/libostree.bst
- extensions/devel/filesystem.bst
- extensions/devel/include.bst