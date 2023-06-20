kind: ostree

config:
  environment:
  - components/libostree.bst
  
  ostree-branch: "%{extension-prefix}/nvidia"

build-depends:
- components/libostree.bst
- extensions/nvidia/nvidia-settings.bst
- extensions/nvidia/pkg.bst