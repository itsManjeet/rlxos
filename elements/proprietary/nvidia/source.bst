kind: manual

sources:
  - kind: remote
    url: https://us.download.nvidia.com/XFree86/Linux-x86_64/525.89.02/NVIDIA-Linux-x86_64-525.89.02.run

    ref: 0e412c88c5bd98f842a839a6f64614f20e4c0950ef7cffb12b158a71633593e9
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
  configure-commands:
    - sed -i 's#/dev/tty#/dev/stderr#g' NVIDIA-Linux-x86_64-525.89.02.run
    - sed -i '697,713d' NVIDIA-Linux-x86_64-525.89.02.run
    - sed -i 's#skip=845#skip=828#' NVIDIA-Linux-x86_64-525.89.02.run
  install-commands:
    - sh ./NVIDIA-Linux-x86_64-525.89.02.run --ui=none -x --target %{install-root}/nvidia
    - sh ./NVIDIA-Linux-x86_64-525.89.02.run --version-string > %{install-root}/nvidia/nvidiaver
    - cd %{install-root}/nvidia && tar -xf nvidia-persistenced-init.tar.bz2

  strip-commands:
    - true