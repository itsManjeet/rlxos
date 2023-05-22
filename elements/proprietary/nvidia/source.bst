kind: manual

sources:
- kind: remote
  url: https://us.download.nvidia.com/XFree86/Linux-x86_64/530.41.03/NVIDIA-Linux-x86_64-530.41.03.run

  ref: ae27a16a968c85503f5d161dda343c1602612b025f4aee15f92e2ea0acb784b1
depends:
- freedesktop-sdk.bst:bootstrap-import.bst

build-depends:
- freedesktop-sdk.bst:bootstrap/xz.bst
- freedesktop-sdk.bst:components/which.bst
- freedesktop-sdk.bst:components/tar.bst

environment:
  SETUP_NOCHECK: 1

sandbox:
  build-uid: 1000
  build-gid: 1000

config:
  install-commands:
  - sh ./NVIDIA-Linux-x86_64-530.41.03.run --ui=none -x --target %{install-root}/nvidia/
  - sh ./NVIDIA-Linux-x86_64-530.41.03.run --version-string > %{install-root}/nvidia/nvidiaver
  - tar -xf %{install-root}/nvidia/nvidia-persistenced-init.tar.bz2 -C %{install-root}/nvidia/

  strip-commands:
  - true
