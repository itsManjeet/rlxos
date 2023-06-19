kind: ostree

config:
  environment:
  - components/libostree.bst
  
  ostree-branch: "%{arch}/%{variant}/extension/nvidia"

build-depends:
- components/libostree.bst
- proprietary/nvidia/nvidia-settings.bst
- proprietary/nvidia/pkg.bst