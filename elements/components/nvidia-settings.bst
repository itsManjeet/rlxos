kind: make

depends:
- components/gtk+-3.bst
- freedesktop-sdk.bst:components/jansson.bst
- freedesktop-sdk.bst:components/libvdpau.bst
- freedesktop-sdk.bst:components/xorg-lib-xv.bst
- freedesktop-sdk.bst:components/xorg-lib-xxf86vm.bst
- proprietary/nvidia/pkg.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

config:
  install-commands:
    (>):
    # FIX libdir
    - |
      mkdir -p %{install-root}%{libdir}/
      mv %{install-root}%{indep-libdir}/libnvidia-*.so.* %{install-root}%{libdir}/
    - install -Dm644 -t %{install-root}%{datadir}/applications/ doc/nvidia-settings.desktop
    - install -Dm644 -t %{install-root}%{datadir}/pixmaps/ doc/nvidia-settings.png
    - |
      sed \
        -e 's:__UTILS_PATH__:%{bindir}:' \
        -e 's:__PIXMAP_PATH__:%{datadir}/pixmaps:' \
        -e 's/__NVIDIA_SETTINGS_DESKTOP_CATEGORIES__/Settings;HardwareSettings;/' \
        -e 's/Icon=.*/Icon=nvidia-settings/' \
        -i "%{install-root}%{datadir}/applications/nvidia-settings.desktop"

sources:
- kind: git_tag
  url: github:NVIDIA/nvidia-settings.git
  track: main
  ref: 530.41.03-0-g8c0ba0680bd4941dc66b471ed2b3fc13f661e45d
