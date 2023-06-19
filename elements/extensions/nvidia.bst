kind: ostree

config:
  environment:
  - components/libostree.bst
  
  ostree-branch: "%{arch}/extension/nvidia"

build-depends:
- components/libostree.bst
- proprietary/nvidia/pkg.bst